#!/usr/bin/env fish

function tasks -d "Manage personal tasks"
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
        if not count $argv > /dev/null
          v $tasks_file
        else
          set -g selected_task_id $argv[1]
          set -g selected_task "(.tasks[] | select(.id == $selected_task_id))"
          if not __tasks_check_id; __tasks_unset_variables; return 6; end
          if not __tasks_edit $argv[2]; __tasks_unset_variables; return 8; end
        end
      case 'delete'
        if set -q selected_priority
          if not __tasks_delete 'priority' \"$selected_priority\"; __tasks_unset_variables; return 7; end
        else if count $argv > /dev/null
          if not __tasks_delete 'id' $argv[1]; __tasks_unset_variables; return 7; end
        else
          if not __tasks_delete_all; __tasks_unset_variables; return 4; end
        end
    end
  else if set -q selected_priority
    if not count $argv > /dev/null
      __tasks_print $selected_priority
    else
      if not __tasks_create "$argv[1]" $selected_priority; __tasks_unset_variables; return 5; end
    end
  else if set -q _flag_priority
    __tasks_print 'low'
    __tasks_print 'normal'
    __tasks_print 'high'
  else
    if not count $argv > /dev/null
      __tasks_print
    else
      if not __tasks_create "$argv[1]" 'normal'; __tasks_unset_variables; return 5; end
    end
  end

  __tasks_unset_variables
  return 0
end

function __tasks_create
  set index (jq '.next_index' $tasks_file)
  set date (date '+%d/%m %H:%M')
  set capital_task (string_capitalize $argv[1])
  set prefix_abbreviation (string sub -l 1 (string_capitalize $argv[2]))

  __tasks_inplace_write ".tasks += [{
    id: $index,
    task: \"$capital_task\",
    priority: \"$argv[2]\",
    date: \"$date\"
  }]"
  __tasks_inplace_write ".next_index += 1"

  __tasks_commit_changes "Create task \"[$prefix_abbreviation] $capital_task\" with id $index" "Task \"$capital_task\" created. ID: $index"
  return $status
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
    echo -e 'NO TASKS\n'
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

function __tasks_edit
  set new_date (date '+%d/%m %H:%M')
  set operations "$selected_task.date = \"$new_date\""

  if set -q selected_priority
    set operations $operations "| $selected_task.priority = \"$selected_priority\""
  end

  if count $argv > /dev/null
    set operations $operations "| $selected_task.task = \"$argv\""
  end

  __tasks_inplace_write $operations

  __tasks_commit_changes "Edit task #$selected_task_id" "Task #$selected_task_id edited"
  return $status
end

function __tasks_delete
  set key $argv[1]
  set value $argv[2]
  set filter ".tasks[] | select(.$key == $value)"
  set affected_tasks (jq "[$filter] | length" $tasks_file)

  __tasks_inplace_write "del($filter)"

  __tasks_commit_changes "Delete tasks with a condition '$key' equals to '$value'" "$affected_tasks task(s) deleted"
  return $status
end

function __tasks_delete_all
  echo '{"next_index": 0, "tasks": []}' | jq '.' > $tasks_file

  __tasks_commit_changes 'Delete all tasks' 'All tasks deleted'
  return $status
end

function __tasks_check_file
  if test ! -f $tasks_file
    echo "Tasks file ($tasks_file) doesn't exist"
    set -e tasks_file
    return 1
  end
  return 0
end

function __tasks_check_json_formatting
  if not jq '.' $tasks_file > /dev/null 2> /dev/null
    echo 'The tasks file has JSON formatting errors.'
    echo "Please check this file: $tasks_file"
    return 1
  end
  return 0
end

function __tasks_check_id
  set target (jq "$selected_task | has(\"task\")" $tasks_file)
  if test "$target" != 'true'
    echo "Task #$selected_task_id doesn't exist"
    return 1
  end
  return 0
end

function __tasks_inplace_write
  set filter $argv
  set tmp_file /tmp/(date +%N)

  echo "Filter applied: $filter"
  read
  jq "$filter" $tasks_file > $tmp_file
  mv $tmp_file $tasks_file
end

function __tasks_commit_changes
  set commit_message $argv[1]
  set success_message $argv[2]
  
  g -C (dirname $tasks_file) add -A
  g -C (dirname $tasks_file) commit -qm $commit_message

  if test $status -eq 0
    echo $success_message
    return 0
  end
  return 1
end

function __tasks_unset_variables
  set -e selected_priority
  set -e selected_operation
  set -e selected_task
end

