module filesize

import logx

[rotation: 'filesize']
pub struct FileLog {
pub mut:
	trace_    logx.LevelInfo [cap: 10000; file: 'logs/trace.log'; max_size: '1MB']
	debug_    logx.LevelInfo [cap: 9000; file: 'logs/debug.log'; max_size: '1MB']
	info_     logx.LevelInfo [cap: 8000; file: 'logs/info.log'; max_size: '1MB']
	note_     logx.LevelInfo [cap: 7000; file: 'logs/note.log'; max_size: '1MB']
	warn_     logx.LevelInfo [cap: 1000; file: 'logs/warn.log'; max_size: '1MB']
	alert_    logx.LevelInfo [cap: 1000; file: 'logs/alert.log'; max_size: '1MB']
	error_    logx.LevelInfo [cap: 1000; file: 'logs/error.log'; max_size: '1MB']
	fatal_    logx.LevelInfo [cap: 1; file: 'logs/fatal.log'; max_size: '1MB']
	log_level int
}

pub enum LogLevel {
	trace
	debug
	info
	note
	warn
	alert
	error
	fatal
}

pub fn (mut l FileLog) set_level(level LogLevel) {
	l.log_level = int(level)
}

pub fn (mut l FileLog) wait_all() {
	logx.wait(mut l)
}

pub fn (mut l FileLog) wait(level LogLevel) {
	match level {
		.trace {
			l.trace_.wg.wait()
		}
		.debug {
			l.debug_.wg.wait()
		}
		.info {
			l.info_.wg.wait()
		}
		.note {
			l.note_.wg.wait()
		}
		.warn {
			l.warn_.wg.wait()
		}
		.alert {
			l.alert_.wg.wait()
		}
		.error {
			l.error_.wg.wait()
		}
		.fatal {
			l.fatal_.wg.wait()
		}
	}
}

pub fn (mut l FileLog) flush_all() {
	l.trace_.ofile.flush()
	l.debug_.ofile.flush()
	l.info_.ofile.flush()
	l.note_.ofile.flush()
	l.warn_.ofile.flush()
	l.alert_.ofile.flush()
	l.error_.ofile.flush()
	l.fatal_.ofile.flush()
}

pub fn (mut l FileLog) flush(level LogLevel) {
	match level {
		.trace {
			l.trace_.ofile.flush()
		}
		.debug {
			l.debug_.ofile.flush()
		}
		.info {
			l.info_.ofile.flush()
		}
		.note {
			l.note_.ofile.flush()
		}
		.warn {
			l.warn_.ofile.flush()
		}
		.alert {
			l.alert_.ofile.flush()
		}
		.error {
			l.error_.ofile.flush()
		}
		.fatal {
			l.fatal_.ofile.flush()
		}
	}
}

pub fn (mut l FileLog) ensure(level LogLevel) {
	match level {
		.trace {
			l.trace_.wg.wait()
			l.trace_.ofile.flush()
		}
		.debug {
			l.debug_.wg.wait()
			l.debug_.ofile.flush()
		}
		.info {
			l.info_.wg.wait()
			l.info_.ofile.flush()
		}
		.note {
			l.note_.wg.wait()
			l.note_.ofile.flush()
		}
		.warn {
			l.warn_.wg.wait()
			l.warn_.ofile.flush()
		}
		.alert {
			l.alert_.wg.wait()
			l.alert_.ofile.flush()
		}
		.error {
			l.error_.wg.wait()
			l.error_.ofile.flush()
		}
		.fatal {
			l.fatal_.wg.wait()
			l.fatal_.ofile.flush()
		}
	}
}

pub fn (mut l FileLog) set_level_max_size(level LogLevel, max_size u64) {
	$for field in FileLog.fields {
		$if field.is_struct {
			$if field.typ is logx.LevelInfo {
				if l.$(field.name).priority == int(level) {
					l.$(field.name).max_size = max_size
				}
			}
		}
	}
}

pub fn (mut l FileLog) set_level_rotation_output_dir(level LogLevel, dir string) ! {
	$for field in FileLog.fields {
		$if field.is_struct {
			$if field.typ is logx.LevelInfo {
				if l.$(field.name).priority == int(level) {
					logx.set_rotation_outputdir(mut l.$(field.name), dir)!
				}
			}
		}
	}
}

pub fn (mut l FileLog) set_all_rotation_output_dir(dir string) ! {
	$for field in FileLog.fields {
		$if field.is_struct {
			$if field.typ is logx.LevelInfo {
				logx.set_rotation_outputdir(mut l.$(field.name), dir)!
			}
		}
	}
}

pub fn (mut l FileLog) trace(s string) {
	if l.log_level > int(LogLevel.trace) {
		return
	}
	logx.check_level_size_rotation(mut l.trace_)
	logx.send(mut l.trace_, l.trace_.formatter(s, 'TRACE'))
}

pub fn (mut l FileLog) debug(s string) {
	if l.log_level > int(LogLevel.debug) {
		return
	}
	logx.check_level_size_rotation(mut l.debug_)
	logx.send(mut l.debug_, l.debug_.formatter(s, 'DEBUG'))
}

pub fn (mut l FileLog) info(s string) {
	if l.log_level > int(LogLevel.info) {
		return
	}
	logx.check_level_size_rotation(mut l.info_)
	logx.send(mut l.info_, l.info_.formatter(s, 'INFO'))
}

pub fn (mut l FileLog) note(s string) {
	if l.log_level > int(LogLevel.note) {
		return
	}
	logx.check_level_size_rotation(mut l.note_)
	logx.send(mut l.note_, l.note_.formatter(s, 'NOTE'))
}

pub fn (mut l FileLog) warn(s string) {
	if l.log_level > int(LogLevel.warn) {
		return
	}
	logx.check_level_size_rotation(mut l.warn_)
	logx.send(mut l.warn_, l.warn_.formatter(s, 'WARN'))
}

pub fn (mut l FileLog) alert(s string) {
	if l.log_level > int(LogLevel.alert) {
		return
	}
	logx.check_level_size_rotation(mut l.alert_)
	logx.send(mut l.alert_, l.alert_.formatter(s, 'ALERT'))
}

pub fn (mut l FileLog) error(s string) {
	if l.log_level > int(LogLevel.error) {
		return
	}
	logx.check_level_size_rotation(mut l.error_)
	logx.send(mut l.error_, l.error_.formatter(s, 'ERROR'))
}

pub fn (mut l FileLog) fatal(s string) {
	if l.log_level > int(LogLevel.fatal) {
		return
	}
	logx.check_level_size_rotation(mut l.fatal_)
	logx.send(mut l.fatal_, l.fatal_.formatter(s, 'FATAL'))
	logx.wait(mut l)
	l.fatal_.wg.wait()
	panic(s)
}

pub fn new() !&FileLog {
	return logx.from_new(FileLog{})!
}
