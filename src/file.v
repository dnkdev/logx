module logx

import time
import os

fn listen_file_channel(mut log_info LevelInfo) {
	for {
		t := <-log_info.ch or {
			break
		}
		$if logx_console ? {
			println(t)
		}
		repeat:
		log_info.ofile.writeln(t) or {
			eprintln(@MOD + ' ' + @FN + ': ' + err.str() + '\n     ' + t)
			if err is os.FileNotOpenedError{
				time.sleep(1 * time.second)
				unsafe {
					goto repeat
				}
			}
		}
		log_info.wg.done()
	}
}

fn get_daily_file_path(path string) string {
	ext := os.file_ext(path)
	return path.all_before('.') + '-' + time.now().ymmdd() + ext
}

pub fn send[T](mut logger T, s string) {
	logger.wg.add(1)
	logger.ch <- s
}

pub fn wait[T](mut logger T){
	$for field in T.fields {
		$if field.typ is LevelInfo {
			logger.$(field.name).wg.wait()
		}
	}
}

[inline]
pub fn wait_level(mut log_level LevelInfo){
	log_level.wg.wait() 
}
