
(defconst lexlite-default-state :base)
(defconst lexlite-state-stack nil)
(defconst lexlite-state :base)

(defconst lexlite-rules nil)

(defun lexlite-find-matches (rules)
  (let ((matches nil))
    (dolist (rule rules)
      (let ((pattern (car rule)))
        (save-excursion
          (when (re-search-forward pattern nil t)
            (push (list rule (match-data)) matches)))))
    (sort (reverse matches) (lambda (a b) (< (caadr a) (caadr b))))))

(defun lexlite-apply-action (action)
  (let ((subexpr (car action))
        (actor (cadr action))
        (state (caddr action)))
    (cond
     ((functionp actor)
      (apply actor subexpr args))
     (t
      (let ((start (match-beginning subexpr))
            (end (match-end subexpr)))
        (when (and start end)
          (unless (stringp actor)
            (add-text-properties start
                                 end
                                 (list 'face actor
                                       'lexlite-start (set-marker (make-marker) start)
                                       'lexlite-state lexlite-state
                                       'lexlite-state-stack lexlite-state-stack)))))
      (case state
        ((nil))
        ((pop)
         (setq lexlite-state (pop lexlite-state-stack)))
        (t
         (push lexlite-state lexlite-state-stack)
         (setq lexlite-state state)))))))

(defconst lexlite-skip nil)

(defun lexlite-apply-match (actions)
  (let* ((place (1- (match-end 0)))
         (props (copy-list (text-properties-at place))))
    (lexlite-apply-action (list 0 'default))
    (dolist (action actions)
      (if (listp action)
          (lexlite-apply-action action)
        (lexlite-apply-action (list 0 action))))
    (goto-char (match-end 0))
    (if (not (equal props (text-properties-at place)))
        t
      ;;(y-or-n-p (format "Formatting not changed here: %s -> %s" props (text-properties-at place)))
      (if (< lexlite-skip (point))
          nil
        t))))

(defun lexlite-fontify-region (start end)
  (let (matches)
    (save-excursion
      (goto-char start)
      ;;(remove-text-properties start end '(face face))
      (while
          (and (< (point) end)
               (setq start (point-marker))
               (setq match (car (lexlite-find-matches (plist-get (if (symbolp lexlite-rules)
                                                                     (eval lexlite-rules)
                                                                   lexlite-rules)
                                                                 lexlite-state))))
               (save-match-data
                 (set-match-data (cadr match))
                 (when (match-beginning 0)
                   (add-text-properties start (match-beginning 0)
                                        (list 'face default
                                              'lexlite-start start
                                              'lexlite-state lexlite-state
                                              'lexlite-state-stack lexlite-state-stack)))
                 (funcall #'lexlite-apply-match (car match))))))))

(defun lexlite-fontify-from-point ()
  (interactive)
  (save-excursion
    (setq lexlite-skip (point))
    (beginning-of-line)
    (goto-char (1- (or (get-text-property (point) 'lexlite-start) 2)))
    (goto-char (or (get-text-property (point) 'lexlite-start) 1))
    (let ((lexlite-state (get-text-property (point) 'lexlite-state))
          (lexlite-state-stack (get-text-property (point) 'lexlite-state-stack)))
      (lexlite-fontify-region (point) (point-max)))))

(defun lexlite-fontify-buffer ()
  (interactive)
  (save-restriction
    (widen)
    (setq lexlite-state-stack nil)
    (setq lexlite-state lexlite-default-state)
    (remove-text-properties (point-min) (point-max) '(xface nil lexlite-state nil lexlite-state-stack nil lexlite-start nil))
    (lexlite-fontify-region (point-min) (point-max))))

(defun lexlite-after-change (start end length)
  ;;(y-or-n-p "!")
  ;(condition-case x
      (lexlite-fontify-from-point)
  ;  (error))
  )

(defun lexlite-post-command ()
  ;;(message "%s" (text-properties-at (point)))
  )

(defun lexlite-mode-on ()
  (interactive)
  (make-local-variable 'after-change-functions)
  (make-local-variable 'post-command-hook)
  (add-hook 'after-change-functions #'lexlite-after-change)
  (add-hook 'post-command-hook #'lexlite-post-command)
  (lexlite-fontify-buffer)
  )

(defun lexlite-mode-off ()
  (interactive)
  (remove-hook 'after-change-functions #'lexlite-after-change))
