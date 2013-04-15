"use strict";

module.exports = {
	reporter: function (results, data, opts) {
		var len = results.length;
		var str = '';
		var prevfile;

		opts = opts || {};

		results.forEach(function (result) {
			var file = result.file;
			var error = result.error;

			if (prevfile && prevfile !== file) {
				str += "\n";
			}
			prevfile = file;

			str += error.line + ':' +
				error.character + ':' +
				error.code + ':' +
                '0:' +
				error.reason;

			if (opts.verbose) {
				str += ' (' + error.code + ')';
			}

			str += '\n';
		});

		if (str) {
			process.stdout.write(str);
			//process.stdout.write(str + "\n" + len + ' error' + ((len === 1) ? '' : 's') + "\n");
		}
	}
};
