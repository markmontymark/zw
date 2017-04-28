#!/usr/bin/env node

'use strict';

var fs = require('graceful-fs');
var path = require('path');
var walk = require('walk');

var dates = {};

var dir = process.argv.slice(2)[0];
walk.walk(dir,{followLinks: false}).
on('file',function (root,stat,next) {
  var sn = stat.name;
  if(sn.substring(sn.length - 5) === '.html'){
    //console.log(sn);
		fs.readFile(path.join(dir,sn),function(err,data){
			if(err){
				console.log(err);
				return;
			}
			(data.
				toString('utf8').
				match(/(\d+\/\d+\/\d+\s+\d+:\d+:\d+\s*[ap]m)/ig)
			|| []).
				forEach(checkDate(sn));
		});
	}
  next();
}).
on('errors', function  (root, stat, next){
  console.log(stat.name,'errors in ',root,' ',stat);
  next();
});

function checkDate (sn){
	return function(date){
		if(dates[date] && dates[date] !== sn){
			console.log(' already found ', date, ' in ',dates[date], ' now at ',sn);
		}
		else{
			dates[date] = sn;
		}
	};
}
