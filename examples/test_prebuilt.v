module main

import log
import time
//import logx.prebuilt.filesize.filelog
import logx.prebuilt.daily.filelog


fn start_vlog(repeats int) string{
	mut vlog := log.Log{}
	vlog.set_level(.debug)
	vlog.set_full_logpath('./debug_vlog.log')
	bench := time.ticks()
	for i in 0..repeats {
		vlog.debug('Some text ${i}')
		vlog.info('Some text ${i}')
		vlog.warn('Some text ${i}')
		vlog.error('Some text ${i}')
	}
	return 'vLog Time: ${time.ticks() - bench}ms'
}

fn start_logx(repeats int)! string {
	mut logger := filelog.new()!
	logger.set_level(.trace)
	dump(logger)
	bench := time.ticks()
	for i in 0..repeats {
		logger.trace('Some text ${i}')
		logger.debug('Some text ${i}')
		logger.info('Some text ${i}')
		logger.note('Some text ${i}')
	}
	return 'logX Time: ${time.ticks() - bench}ms'
}

fn main(){
	mut repeats := 10000
	txt_logx := start_logx(repeats)!
	txt_vlog := start_vlog(repeats)
	

	C.atexit(
		fn[txt_logx, txt_vlog](){
			println(txt_vlog)
			println(txt_logx)
		}
	)
	//time.sleep(2000*time.millisecond)
}