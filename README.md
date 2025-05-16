*** memgit.el: An In-Memory Git for Fast Iteration

~memgit.el~ is a minor mode for Emacs that provides in-memory versioning for files. It allows you to save, load, and manage file versions in a cache directory, enabling fast iteration without the need for a full-fledged version control system.

** Features
+ Save and load file versions in a dedicated cache directory.
+ Navigate between previous and next versions of a file.
+ Add descriptions to versions for better context.
+ Clear all versions for a file when needed.
+ Lightweight and easy to use.

** Installation
1. Clone the repository:
   ``` shell
   git clone https://github.com/param108/memgit.el.git
   ```

2. Add the following to your Emacs configuration file (e.g., `~/.emacs.d/init.el` or `~/.config/doom/config.el`):
   ``` emacs-lisp
   (add-to-list 'load-path "~/path/to/memgit.el")
   (require 'memgit)
   ```

3. Restart Emacs or evaluate the above lines.

** Usage
To enable ~memgit-mode~ in a buffer, run:
``` emacs-lisp
M-x memgit-mode
```

Keybindings provided by ~memgit-mode~:
+ ~C-c m n~: Replace the current file with the next version.
+ ~C-c m p~: Replace the current file with the previous version.
+ ~C-c m v~: Display the current version of the file.
+ ~C-c m d~: Display the description of the current version.
+ ~C-c m s~: Save the current file as a new version with a description.

** Doom Emacs Configuration
For Doom Emacs users, add the following to your `~/.config/doom/config.el`:
``` emacs-lisp
(use-package! memgit)

(after! memgit  
  (progn
    (memgit-setup)
    (memgit-load-versions)))
```

`.config/doom/packages.el`:
``` emacs-lisp
(package! memgit :recipe (:repo "param108/memgit.el" :files ("*.el")))
```

Now run
```
doom sync
```

and you should be all set.
** Setting Up the Cache Directory
Run the following command to initialize the cache directory:
``` emacs-lisp
M-x memgit-setup
```

This will create the cache directory (default: `~/memgit-cache/`) and initialize the versioning system.

** Contributing
Contributions are welcome! Feel free to open issues or submit pull requests on the [GitHub repository](https://github.com/param108/memgit.el).

** License
This package is not part of GNU Emacs.

