# vim-bgtags

This plugin generates and maintains ctags files in the background, using vim 8's new job features.

## Requirements

* Your tags file's gotta go in the current working directory and be called `tags`.

## Installation

Use [pathogen](https://github.com/tpope/vim-pathogen/) and clone this repo to `~/.vim/bundle`, or whatever vim package manager the cool kids are using these days.

## Usage

`:BgtagsUpdateTags` regenerates the tags for your project.

[`:help bgtags`](./doc/bgtags.txt) for more.
