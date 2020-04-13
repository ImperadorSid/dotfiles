#!/usr/bin/env fish

function tasks -d "Manage personal tasks"
  set -g tasks_file ~/Documents/Books/Tasks/tasks.json
  if not __tasks_check_file; return 1; end
  if not __tasks_check_json_formatting; return 3; end  

  set options 'p/priority' 'l/low' 'n/normal' 'h/high' 'e/edit' 'd/delete'
  argparse -n 'Tasks' -x 'p,e,d' -x 'p,l,n,h' $options -- $argv
  if test $status -ne 0; return 2; end

  if set -q _flag_low; set -g selected_priority 'low'; end
  if set -q _flag_normal; set -g selected_priority 'normal'; end
  if set -q _flag_high; set -g selected_priority 'high'; end

  if set -q _flag_edit; set -g selected_operation 'edit'; end
  if set -q _flag_delete; set -g selected_operation 'delete'; end

  if set -q selected_operation
    switch $selected_operation
      case 'edit'
        echo 'Edit'
      case 'delete'
        if set -q selected_priority
          echo "Delete all $selected_priority priority tasks"
        else if count $argv > /dev/null
          echo "Delete tasks with ids $argv"
          __tasks_delete_by_id $argv
        else
          __tasks_delete_all
        end
    end
  else if set -q selected_priority
    if not count $argv > /dev/null
      __tasks_print $selected_priority
    else
      __tasks_create "$argv" $selected_priority
    end
  else if set -q _flag_priority
    __tasks_print 'low'
    __tasks_print 'normal'
    __tasks_print 'high'
  else
    if not count $argv > /dev/null
      __tasks_print
    else
      __tasks_create "$argv" 'normal'
    end
  end

  #set -e tasks_file
  set -e selected_priority
  set -e selected_operation
  return 0
end

function __tasks_print
  if not count $argv > /dev/null
    set filter '[.tasks[]]'
    echo 'All tasks'
  else
    set filter "[.tasks[] | select(.priority == \"$argv\")]"
    echo "Tasks with $argv priority"
  end

  set tasks_count (jq "$filter | length" $tasks_file)

  if test $tasks_count -eq 0
    echo "NO TASKS"
    return
  end

  echo ' ID | DATE        | TASK'
  for i in (seq 0 (math "$tasks_count - 1"))
    set id (jq -r "$filter [$i].id" $tasks_file)
    set task (jq -r "$filter [$i].task" $tasks_file)
    set date (jq -r "$filter [$i].date" $tasks_file)
    set priority (jq -r "$filter [$i].priority" $tasks_file)

    switch $priority
      case 'low'
        set task_color $fish_color_comment
      case 'normal'
        set task_color $fish_color_quote
      case 'high'
        set task_color $fish_color_error
    end

    printf '%s%3d | %s | %s\n%s' (set_color $task_color) $id $date $task (set_color normal)
  end

  echo -e "  TOTAL: $tasks_count tasks\n"
end

function __tasks_check_file
  if test ! -f $tasks_file
    echo "Tasks file ($tasks_file) doesn't exist"
    set -e tasks_file
    return 1
  end
  return 0
end

function __tasks_create
  set index (jq .next_index $tasks_file)
  set date (date '+%d/%m %H:%M')
  set tmp_file /tmp/(date +%N)

  jq ".tasks += [{
        id: $index,
        task: \"$argv[1]\",
        priority: \"$argv[2]\",
        date: \"$date\"
      }]" $tasks_file > $tmp_file
  mv $tmp_file $tasks_file

  jq ".next_index += 1" $tasks_file > $tmp_file
  mv $tmp_file $tasks_file

  __tasks_commit_changes "Create task \"$argv[1]\" with id $index"
end

function __tasks_check_json_formatting
  if not jq . $tasks_file > /dev/null 2> /dev/null
    echo 'The tasks file has JSON formatting errors.'
    echo "Please check this file: $tasks_file"
    return 1
  end
  return 0
end

function __tasks_delete_all
  echo '{"next_index": 0, "tasks": []}' | jq . > $tasks_file

  __tasks_commit_changes 'Delete all tasks'
  echo 'All tasks deleted'
end

function __tasks_commit_changes
  g -C (dirname $tasks_file) add -A
  g -C (dirname $tasks_file) commit -qm $argv
end

