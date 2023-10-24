module logx

import os

struct MyLog{
	trace LevelInfo [file: 'test__logs/test.log'; cap: 8888]
	debug LevelInfo [file: 'test__logs/debug.log'; cap: 10000]
	info  LevelInfo [file: 'test__logs/info/test.log'; cap: 10000]
	note  LevelInfo [file: 'test__logs/info/test.log'; cap: 10000]
	warn  LevelInfo [file: 'test__logs/test.log'; cap: 10000]
	alert LevelInfo [file: 'test__logs/test.log'; cap: 10000]
	error LevelInfo [file: 'test__logs/test.log'; cap: 10000]
	fatal LevelInfo [file: 'test__logs/test.log'; cap: 7777]
}


fn test_from_new()!{
	mut l := from_new[MyLog]()!
	path := 'test__logs/info/test.log'
	//dump(l)
	assert l.debug.ch.cap == 10000
	assert l.fatal.ch.cap == 8888 // 8888 because file for fatal == file for trace, 1 channel is used
	assert l.info.file_path == path
	assert os.exists(path)
	assert l.debug.file_path != l.trace.file_path
	assert l.trace.file_path == l.fatal.file_path
	os.rmdir_all('test__logs')or{}
}
