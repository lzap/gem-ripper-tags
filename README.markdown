RubyGems Automatic Ctags Generator
==================================

If you do like Vim and Ctags like I or [Tim Pope][] do, you maybe appreciate
automatic generation of ctags for each installed gem. This small project is
based on Tim's [gem-ctags][], but the main difference is it does *not* use
[Exuberant Ctags][].

Upstream site is at: https://github.com/lzap/gem-ripper-tags

Usage
-----

Install the thing (only Ruby 1.9+):

    gem install gem-ripper-tags

Then generate tags for all already installed gems:

    gem ripper_tags

Anytime you install a gem now, tags will be automatically created.

    gem instal some_gem ...

If you're using RVM, I recommend extending your global gemset by adding
`gem-ripper-tags` to `~/.rvm/gemsets/global.gems`.  Put it at the top so the
gems below it will be indexed.

You can use the gem even with 1.8 gemsets, but since Ruby 1.8 is not
supported, it will (silently) not register the gem hook.

Motivation
----------

Why would you care about not using ctags in the first place? Ctags is a great
project and it does support many (like 50) languages. But Ruby support is very
weak, the parser is not in good condition and it has not been changed 4 years
now.

 * Ctags doesn't deal with: module A::B
 * Ctags doesn't tag (at least some of) the operator methods like ==
 * Ctags doesn't support qualified tags, -type=+
 * Ctags doesn't output tags for constants or attributes.

Unfortunately all the others (I found 2) Ruby ctags generators are either
outdated (no Ruby 1.9+ support) or very slow. This project makes use of
[ripper-tags][] that leverages built-in Ruby parser API called Ripper. It is
fast and it works as expected.

Vim Tips
--------

To easily edit a gem with your current working directory set to the
gem's root, install [gem-browse][].

If you have [rake.vim][] installed (which, by the way, is a misleading
name), Vim will already know where to look for the tags file when
editing a gem.

If you have [bundler.vim][] installed, Vim will be aware of all tags
files from all gems in your bundle.

If you want to get crazy, add this to your vimrc to get Vim to search
all gems in your current RVM gemset (requires [pathogen.vim][]):

    autocmd FileType ruby let &l:tags = pathogen#legacyjoin(pathogen#uniq(
          \ pathogen#split(&tags) +
          \ map(split($GEM_PATH,':'),'v:val."/gems/*/tags"')))

Tim Pope doesn't like to get crazy. ;-)

License
-------

Copyright (c) Tim Pope; Lukáš Zapletal. MIT License.

[Tim Pope]: http://tpo.pe/
[Exuberant Ctags]: http://ctags.sourceforge.net/
[gem-ctags]: https://github.com/tpope/gem-ctags
[gem-browse]: https://github.com/tpope/gem-browse
[bundler.vim]: https://github.com/tpope/vim-bundler
[pathogen.vim]: https://github.com/tpope/vim-pathogen
[rake.vim]: https://github.com/tpope/vim-rake
[ripper-tags]: https://github.com/tmm1/ripper-tags
