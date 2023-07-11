module logx

import time
import os

fn listen_file_channel[T](mut logger T ,ch chan string, prior int) {
	for {
		t := <-ch or {
			break
		}
		$if logx_console ? {
			println(t)
		}
		repeat:
		$for field in T.fields {
			$if field.typ is LevelInfo {
				if logger.$(field.name).priority == prior {
					logger.$(field.name).ofile.writeln(t) or {
						eprintln(@MOD + ' listen_file_channel: ' + err.str() + '\n    ' + t)
						time.sleep(3*time.second)
						unsafe {
							goto repeat
						}
					}
				}
			}
		}
	}
}

fn get_daily_file_path(path string) string {
	ext := os.file_ext(path)
	return path.all_before('.') + '-' + time.now().ymmdd() + ext
}

// TODO: make wait better
pub fn wait[T](mut logger T){
	$for field in T.fields {
		$if field.typ is LevelInfo {
			for logger.$(field.name).ch.len != 0 {
				continue
			}
		}
	}
}
fn rotate_daily_files[T](mut logger T)!{
	println('rotate daily')
	$for field in T.fields {
		$if field.is_struct {
			$if field.typ is LevelInfo{
				logger.$(field.name).file_path = get_daily_file_path(get_attr('file', field.attrs)!)
				path := logger.$(field.name).file_path
				logger.log_day = time.now().day_of_week()
				logger.$(field.name).ofile.close()
				logger.$(field.name).ofile = os.open_append(path) or {
					panic(err)
				}
			}
		}
	}
}

pub fn check_daily_rotation[T](mut logger T) {
	if logger.log_day != time.now().day_of_week() {
		rotate_daily_files(mut logger) or {
			eprintln('Error on file rotation: ${err}')
		}
	}
}

[inline]
pub fn is_path_over_size(path string, max_size u64) bool{
	if os.file_size(path) > max_size {
		return true
	}
	return false
}

pub fn rotate_level_by_size(mut log_info LevelInfo) {
	path := log_info.file_path
	ext := os.file_ext(path)
	mut i := 1
	format := time.now().str().replace_each([' ', '_', ':', '-'])
	mut new_file := path.all_before_last('.')+'_${format}${ext}'
	log_info.ofile.close()
	for os.exists(path) {
		os.mv(path, new_file) or {
			eprintln(err)
		}
		i++
		if i == 100 { // for peace of mind
			break
		}
	}
	log_info.ofile = os.open_append(path) or {
		panic(err)
	}
}

[inline]
pub fn check_level_size_rotation(mut log_info LevelInfo) {
	if is_path_over_size(log_info.file_path, log_info.max_size){
		rotate_level_by_size(mut log_info)
	}
}

pub fn check_size_rotation[T](mut logger T) {
	$for field in T.fields {
		$if field.typ is LevelInfo {
			check_level_size_rotation(mut logger.$(field.name))
		}
	}
}