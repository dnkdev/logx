module filesize

import logx

[rotation: 'filesize']
pub struct FileLog {
pub mut:
	trace_    logx.LevelInfo [max_size: '1MB'; cap: 10000; file: 'logs/trace/trace.log']
	debug_    logx.LevelInfo [max_size: '1MB'; cap: 9000; file: 'logs/debug/debug.log']
	info_     logx.LevelInfo [max_size: '1MB'; cap: 8000; file: 'logs/info/info.log']
	note_     logx.LevelInfo [max_size: '1MB'; cap: 7000; file: 'logs/note/note.log']
	warn_     logx.LevelInfo [max_size: '1MB'; cap: 1000; file: 'logs/warn/warn.log']
	alert_    logx.LevelInfo [max_size: '1MB'; cap: 1000; file: 'logs/alert/alert.log']
	error_    logx.LevelInfo [max_size: '1MB'; cap: 1000; file: 'logs/error/error.log']
	fatal_    logx.LevelInfo [max_size: '1MB'; cap: 1; file: 'logs/fatal/fatal.log']
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

pub fn (mut l FileLog) wait() {
	logx.wait(mut l)
}

pub fn (mut l FileLog) set_level(level LogLevel) {
	l.log_level = int(level)
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

pub fn (mut l FileLog) trace(s string) {
	if l.log_level > int(LogLevel.trace) {
		return
	}
	logx.check_level_size_rotation(mut l.trace_)
	l.trace_.ch <- l.trace_.formatter(s, 'TRACE')
}

pub fn (mut l FileLog) debug(s string) {
	if l.log_level > int(LogLevel.debug) {
		return
	}
	logx.check_level_size_rotation(mut l.debug_)
	l.debug_.ch <- l.debug_.formatter(s, 'DEBUG')
}

pub fn (mut l FileLog) info(s string) {
	if l.log_level > int(LogLevel.info) {
		return
	}
	logx.check_level_size_rotation(mut l.info_)
	l.info_.ch <- l.info_.formatter(s, 'INFO ')
}

pub fn (mut l FileLog) note(s string) {
	if l.log_level > int(LogLevel.note) {
		return
	}
	logx.check_level_size_rotation(mut l.note_)
	l.note_.ch <- l.note_.formatter(s, 'NOTE ')
}

pub fn (mut l FileLog) warn(s string) {
	if l.log_level > int(LogLevel.warn) {
		return
	}
	logx.check_level_size_rotation(mut l.warn_)
	l.warn_.ch <- l.warn_.formatter(s, 'WARN ')
}

pub fn (mut l FileLog) alert(s string) {
	if l.log_level > int(LogLevel.alert) {
		return
	}
	logx.check_level_size_rotation(mut l.alert_)
	l.alert_.ch <- l.alert_.formatter(s, 'ALERT')
}

pub fn (mut l FileLog) error(s string) {
	if l.log_level > int(LogLevel.error) {
		return
	}
	logx.check_level_size_rotation(mut l.error_)
	l.error_.ch <- l.error_.formatter(s, 'ERROR')
}

pub fn (mut l FileLog) fatal(s string) {
	if l.log_level > int(LogLevel.fatal) {
		return
	}
	logx.check_level_size_rotation(mut l.fatal_)
	l.fatal_.ch <- l.fatal_.formatter(s, 'FATAL')
	logx.wait(mut l)
	panic(s)
}

pub fn new() !&FileLog {
	return logx.from_new(FileLog{})!
}
