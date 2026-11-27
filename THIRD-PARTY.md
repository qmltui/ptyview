# Third-Party Code

`QmlTui.PtyView` uses the following upstream libraries:

| Library | Version | License | Provisioned by |
| :--- | :--- | :--- | :--- |
| [libvterm](https://www.leonerd.org.uk/code/libvterm/) | 0.3.3 | MIT | `FetchContent` (or `-DQMLTUI_PTYVIEW_USE_SYSTEM_LIBVTERM=ON`) |
| [QmlTui](https://github.com/qmltui/qmltui) | 0.6.x | LGPL-3.0-only | `FetchContent` (or `-DQMLTUI_USE_INSTALLED=ON`) |

## libvterm

MIT License

Copyright (c) 2008 Paul Evans <leonerd@leonerd.org.uk>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
