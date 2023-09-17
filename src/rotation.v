module logx

import os
import time

fn move_file(from string, to string) {
	mut i := 1
	for os.exists(from) {
		os.mv(from, to) or {
			eprintln(err)
		}
		i++
		if i == 100 { // for peace of mind (prevent to go into infinit loop, however it shouldn't happen)
			break
		}
	}
}

fn rotate_daily_files[T](mut logger T)!{
	$for field in T.fields {
		$if field.is_struct {
			$if field.typ is LevelInfo{
				old_file := logger.$(field.name).file_path
				logger.$(field.name).file_path = get_daily_file_path(get_attr('file', field.attrs)!)
				path := logger.$(field.name).file_path
				fname := os.file_name(path)
				dir := logger.$(field.name).rotation_output_dir
				logger.log_day = time.now().day_of_week()
				logger.$(field.name).ofile.close()
				logger.$(field.name).ofile = os.open_append(path) or {
					panic(err)
				}
				move_file(old_file, '${dir}/${fname}')
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
pub fn is_file_over_size(path string, max_size u64) bool{
	if os.file_size(path) > max_size {
		return true
	}
	return false
}

pub fn rotate_level_by_size(mut log_info LevelInfo) {
	path := log_info.file_path
	fname := os.file_name(path).all_before_last('.')
	ext := os.file_ext(path)
	format := time.now().str().replace_each([' ', '_', ':', '-'])
	mut new_file := log_info.rotation_output_dir+'/${fname}_${format}${ext}'
	log_info.ofile.close()
	move_file(path, new_file)
	log_info.ofile = os.open_append(path) or {
		panic(err)
	}
}

[inline]
pub fn check_level_size_rotation(mut log_info LevelInfo) {
	if is_file_over_size(log_info.file_path, log_info.max_size){
		wait_level(mut log_info)
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

// set_rotation_outputdir create a directory if not exists, set the output directory for log files on rotation
pub fn set_rotation_outputdir(mut log_info LevelInfo, dir string)! {
	create_logger_dir_path(dir)
	log_info.rotation_output_dir = dir
}
