# MMMarkdown
MMMarkdown is an Objective-C static library for converting [Markdown][] to HTML. It is compatible with OS X 10.6+ and iOS 5.0+, and is written using ARC.

Unlike other Markdown libraries, MMMarkdown implements an actual parser. It is not a port of the original Perl implementation and does not use regular expressions to transform the input into HTML. MMMarkdown tries to be efficient and minimize memory usage.

[Markdown]: http://daringfireball.net/projects/markdown/

## API
Using MMMarkdown is simple. The main API is a single class method:

    #import "MMMarkdown.h"
    
    NSError  *error;
    NSString *markdown   = @"# Example\nWhat a library!";
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdown error:&error];
    // Returns @"<h1>Example</h1>\n<p>What a library!</p>"

## Downloading
While the development branch (`master`) includes the headers and libraries from the latest release, it is recommended that you use the `release` branch unless you are working on MMMarkdown itself.

## Setup
Adding MMMarkdown to your Mac or iOS project is easy.

1. Copy `include/MMMarkdown.h` and either `lib/libMMMarkdown-Mac.a` or `lib/libMMMarkdown-iOS.a` into your project directory.

    It is probably best to copy these into a folder specifically for files from MMMarkdown. This makes updating in the future easy. Consider placing them under `Frameworks/MMMarkdown`.

2. Add the files you just copied into your Xcode project.

    If you created a directory for those files, you can add the directory itself. It is probably best to place the group that Xcode creates for this directory under the Frameworks group.

You can now use MMMarkdown within your project!

## License
MMMarkdown is available under the [MIT License][].

[MIT License]: http://opensource.org/licenses/mit-license.php

## Roadmap
### 0.3 - Full HTML Support
Because Markdown can contain raw HTML, correctly parsing Markdown requires an HTML parser; otherwise, the HTML may not be passed through correctly. This release will add an HTML parser.

### 0.4 - Performance
This release will focus on the overall performance of MMMarkdown. It should be fast and require little memory.

### 0.5 - Configurability
Having ensured the correctness and performance of MMMarkdown, this release will expand the options accepted by the parser. Plans include a strict mode, which will complain about any parsing errors, and a mode that supports [MultiMarkdown][].

[MultiMarkdown]: http://fletcherpenney.net/multimarkdown/
