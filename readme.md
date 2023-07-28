# 📕 logx

My small library for easier custom logging implementation. File logging.<br>
- [x] One or multiple files / directories
- [x] daily rotation
- [x] filesize rotation

Example implementation (daily rotation, filesize rotation):
<a href="https://github.com/dnkdev/logx/tree/master/filelog">filelog</a><br>
Daily   : `import logx.filelog.daily` <br>
Filesize: `import logx.filelog.filesize`<br>

```v
import logx.filelog.filesize as log

//...
    mut logger := log.new()!
    logger.set_level(.trace)
    
    logger.trace('Some text')
    logger.debug('Some text')
    logger.info('Some text')
    logger.note('Some text')
    logger.warn('Some text')
    logger.alert('Some text')
    logger.error('Some text')
    logger.fatal('Some text') // panic

    logger.wait() 
```

##

(log)X == eXperimental

##