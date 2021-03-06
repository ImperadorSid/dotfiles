#!/usr/bin/env fish

complete -f -c tasks -s p -l 'priority' -d 'Print tasks grouped by priority'
complete -f -c tasks -s l -l 'low' -d 'CRUD for low priority tasks'
complete -f -c tasks -s n -l 'normal' -d 'CRUD for normal priority tasks'
complete -f -c tasks -s h -l 'high' -d 'CRUD for high priority tasks'
complete -f -c tasks -s e -l 'edit' -d 'Edit a task'
complete -f -c tasks -s d -l 'delete' -d 'Delete one or more tasks'
