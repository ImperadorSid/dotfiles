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
          if not __tasks_check_id $argv[1]; __tasks_unset_variables; return 6; end
          if not __tasks_edit $argv; __tasks_unset_variables; return 8; end
        end
      case 'delete'
        if set -q selected_priority
          if not __tasks_delete 'priority' \"$selected_priority\"; __tasks_unset_variables; return 7; end
        else if count $argv > /dev/null
          for t in $argv
            if not __tasks_check_id $t; __tasks_unset_variables; return 6; end
            if not __tasks_delete 'id' $t; __tasks_unset_variables; return 7; end
          end
        else
          if not __tasks_delete_all; __tasks_unset_variables; return 4; end
        end
    end
  else if set -q selected_priority
    if not count $argv > /dev/null
      __tasks_print $selected_priority
    else
      for t in $argv
        if not __tasks_create "$t" $selected_priority; __tasks_unset_variables; return 5; end
      end
    end
  else if set -q _flag_priority
    __tasks_print 'low'
    __tasks_print 'normal'
    __tasks_print 'high'
  else
    if not count $argv > /dev/null
      __tasks_print
    else
      for t in $argv
        if not __tasks_create "$t" 'normal'; __tasks_unset_variables; return 5; end
      end
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

  if not __tasks_inplace_write ".tasks += [{
    id: $index,
    task: \"$capital_task\",
    priority: \"$argv[2]\",
    date: \"$date\"
  }]"; return 1; end
  if not __tasks_inplace_write ".next_index += 1"; return 1; end

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
  set id $argv[1]
  set new_task $argv[2]
  set filter "(.tasks[] | select(.id == $id))"

  set operations '.'

  if set -q selected_priority
    set operations $operations "| $filter.priority = \"$selected_priority\""
  end

  if count $new_task > /dev/null
    set operations $operations "| $filter.task = \"$new_task\""
  end

  set old_task (jq "$filter.task" $tasks_file)
  set old_priority (jq -r "$filter.priority" $tasks_file)

  if not __tasks_inplace_write $operations; return 1; end
  set new_date (date '+%d/%m %H:%M')
  __tasks_inplace_write "$filter.date = \"$new_date\"" > /dev/null

  set new_task (jq "$filter.task" $tasks_file)
  set new_priority (jq -r "$filter.priority" $tasks_file)

  set changes
  if test $old_task != $new_task; set changes "Name: $old_task -> $new_task"; end
  if test $old_priority != $new_priority; set changes $changes "Priority: "(string upper $old_priority)" -> "(string upper $new_priority); end


  set version_control_message "Edit task #$id ("(string join ' / ' $changes)")"
  set output_message "Task #$id edited\n"(string join '\n' $changes)

  __tasks_commit_changes $version_control_message $output_message
  return $status
end

function __tasks_delete
  set key $argv[1]
  set value $argv[2] set filter ".tasks[] | select(.$key == $value)"

  if test $key = 'id'
    set version_control_message "Delete task #$value"
    set output_message "Task #$value deleted"
  else
    set affected_tasks (jq "[$filter] | length" $tasks_file)
    set unquoted_priority (echo $value | tr -d \")

    set version_control_message "Delete $affected_tasks $unquoted_priority priority task(s)"
    set output_message "$affected_tasks $unquoted_priority priority task(s) deleted"
  end

  if not __tasks_inplace_write "del($filter)"; return 1; end
  __tasks_commit_changes $version_control_message $output_message
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
  set id $argv[1]

  if string match -qrv '^\d+$' $id
    echo "\"$id\" isn't a valid task ID"
    return 1
  end

  set target (jq ".tasks[] | select(.id == $id) | has(\"task\")" $tasks_file)
  if test "$target" != 'true'
    echo "Task #$id doesn't exist"
    return 1
  end

  return 0
end

function __tasks_inplace_write
  set filter $argv
  set tmp_file /tmp/(date +%N)

  jq "$filter" $tasks_file > $tmp_file

  if diff -q $tmp_file $tasks_file > /dev/null
    echo 'Nothing changes'
    return 1
  end

  mv $tmp_file $tasks_file
  return 0
end

function __tasks_commit_changes
  set commit_message $argv[1]
  set success_message $argv[2]
  
  g -C (dirname $tasks_file) add -A
  g -C (dirname $tasks_file) commit -qm $commit_message

  if test $status -eq 0
    echo -e $success_message
    return 0
  end
  return 1
end

function __tasks_unset_variables
  set -e selected_priority
  set -e selected_operation
end

