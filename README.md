# memgit.el: Local-only Git for Fast Iteration

**memgit.el** is a minor mode for Emacs that provides versioning for files. It allows you to save, load, and manage file versions in a cache directory, enabling fast iteration without messing up your git history.

## Features
+ Save and load file versions in a dedicated cache directory.
+ Navigate between previous and next versions of a file.
+ Select version to switch to with a menu
+ Add descriptions to versions for better context.
+ Clear all versions for a file when needed.
+ Lightweight and easy to use.

## Installation

### Doom Emacs Configuration
For Doom Emacs users, add the following to your `~/.config/doom/config.el`:
``` emacs-lisp
(use-package! memgit)

(after! memgit
  (progn
    (memgit-setup)
    (memgit-load-versions)
    ;; add this line if you want to load it on every file you open
    (add-hook 'find-file-hook #'memgit-mode)))
```

and this to your `~/.config/doom/packages.el`:
``` emacs-lisp
(package! memgit :recipe (:type git
                          :host github
                          :repo "param108/memgit.el" 
                          :files ("*.el")))
```

Now run
```
doom sync
```

and you should be all set.

## Usage
To enable `memgit-mode` in a buffer, 
(only if you have omitted the `add-hook` line in `config.el`) run:
``` emacs-lisp
M-x memgit-mode
```

Keybindings provided by `memgit-mode`:
+ `C-c m s`: Save the current file as a new version with a description.
+ `C-c m n`: Replace the current file with the next version.
+ `C-c m p`: Replace the current file with the previous version.
+ `C-c m v`: Display the current internal version number of the file.
+ `C-c m d`: Display the description of the current version.
+ `C-c m x`: Delete all saved versions of this file. 
             (There be dragons here. Those who pass here Ne'er return. and all that.)
+ `C-c m a`: Show all versions in the minibuffer and switch to version chosen by user

## Setting Up the Cache Directory
The directory used for the cache directory is stored in the variable 
`memgit-cache-dir` and is set to `~/memgit-cache` by default.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests on the [GitHub repository](https://github.com/param108/memgit.el).

## License
This package is not part of GNU Emacs.

