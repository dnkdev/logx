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
		log_info.ofile.writeln(t) or {
			eprintln(@MOD + ' ' + @FN + ': ' + err.str() + '\n     ' + t)
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
pub fn wait_level(mut log_level LevelInfo){
	for log_level.ch.len != 0 {
		continue
	}
}