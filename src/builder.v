module logx

import os
import time

// from_new create logger from custom struct
pub fn from_new[T](log T) !&T {
	mut logger := &T{}
	mut paths := []string{}
	mut ofiles := []&os.File{}
	mut chanells := []&chan string{}
	mut rotation := ''
	mut has_log_day := false
	// check rotation attribute set
	$for attr in T.attributes {
		$if attr.name == 'rotation' && attr.has_arg {
			rotation = attr.arg
			$if attr.arg == 'daily' {
				$for field in T.fields{
					$if field.name == 'log_day' {
						$if logger.log_day is int {
							has_log_day = true
							logger.log_day = time.now().day_of_week()
						}
					}
				}
			}
		}
	}
	if rotation == 'daily' && !has_log_day {
		panic('for daily rotation add `log_day int` field to `${T.name}`')
	}
	mut i := 0
	// parse LevelInfo fields
	$for field in T.fields {
		$if field.typ is LevelInfo {
			logger.$(field.name).priority = i
			logger.$(field.name).name = field.name
			logger.$(field.name).file_path = get_attr('file', field.attrs)!

			if rotation == 'daily' {
				logger.$(field.name).file_path = get_daily_file_path(logger.$(field.name).file_path)
			}
			else if rotation == 'filesize' {
				max_size := get_attr('max_size', field.attrs)!.all_before('MB').u64()
				logger.$(field.name).max_size = 1024*1024*max_size
				if logger.$(field.name).max_size == 0 {
					panic('file max size can\'t be 0')
				}
			}
			path := logger.$(field.name).file_path

			create_logger_dir_path(path)

			if logger.$(field.name).file_path in paths {
				//println('same file ${path}')
				for a, ofile in ofiles {
					if paths[a] == path {
						logger.$(field.name).ofile = ofile
						logger.$(field.name).ch = chanells[a]
					}
				}
			}
			else {
				paths << path
				logger.$(field.name).ofile = os.open_append(path) or {
					panic(err)
				}
				logger.$(field.name).ch = chan string {cap:get_attr('cap',field.attrs)!.int()}

				ofiles << &logger.$(field.name).ofile
				chanells << &logger.$(field.name).ch

				spawn listen_file_channel(mut &logger.$(field.name))
			}
			i++
		}
	}
	return logger

}

// create_logger_dir_path create directories if they are in file path:
// from "file: 'logs/trace/trace.log'" - create "logs" and "trace" directories
fn create_logger_dir_path(file_path string) {
	mut dir := file_path
	for dir != file_path.all_before('/') {
		dir_path := os.dir(file_path)
		dir = file_path.all_before('/')
		if !os.is_dir(dir_path) {
			os.mkdir_all(dir_path) or {
				panic('${err} ${dir}')
			}
			break
		}
	}
}

fn get_attr(a string, attrs []string) !string{
	for attr in attrs {
		keys := attr.split(':')
		if keys.len != 2{
			panic('wrong declaration of `${keys}`, should be `key: value`')
		}
		akey := keys[0].trim_indent()
		aval := keys[1].trim_indent()
		if akey == a {
			return aval
		}
	}
	return error('`${a}` property not found')
}
