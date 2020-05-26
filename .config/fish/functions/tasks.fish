#!/usr/bin/env fish

function tasks -d "Manage personal tasks"
  __tasks_check_file; or return
  __tasks_check_json_formatting; or return

  set options 'p/priority' 'l/low' 'n/normal' 'h/high' 'e/edit' 'd/delete' 'i/info'
  argparse -n 'Tasks' -x 'p,e,d,i' -x 'p,l,n,h,i' $options -- $argv; or return 2

  set -q _flag_low; and set -g selected_priority 'low'
  set -q _flag_normal; and set -g selected_priority 'normal'
  set -q _flag_high; and set -g selected_priority 'high'

  set -q _flag_edit; and set -g selected_operation 'edit'
  set -q _flag_delete; and set -g selected_operation 'delete'

  if set -q selected_operation
    switch $selected_operation
      case 'edit'
        if test -z "$argv"
          v $tasks_file
        else
          __tasks_check_id $argv[1]; and __tasks_edit $argv
        end
      case 'delete'
        if set -q selected_priority
          __tasks_delete 'priority' \"$selected_priority\"
        else if test -n "$argv"
          for t in $argv
            __tasks_check_id $t; and __tasks_delete 'id' $t
          end
        else
          __tasks_delete_all
        end
    end
  else if set -q selected_priority
    if test -z "$argv"
      __tasks_print $selected_priority
    else
      for t in $argv
        __tasks_create "$t" $selected_priority
      end
    end
  else if set -q _flag_priority
    __tasks_print 'low'
    __tasks_print 'normal'
    __tasks_print 'high'
  else if set -q _flag_info
    __tasks_help
  else
    if test -z "$argv"
      __tasks_print
    else
      for t in $argv
        __tasks_create "$t" 'normal'
      end
    end
  end

  set exit_code $status
  __tasks_unset_variables
  return $exit_code
end

function __tasks_create
  set index (jq '.next_index' $tasks_file)
  set date (date '+%d/%m %H:%M')
  set capital_task (string_capitalize $argv[1])
  set priority_upper (string upper $argv[2])

  set new_task_string ".tasks += [{id: $index, task: \"$capital_task\", priority: \"$argv[2]\", date: \"$date\" }]"
  __tasks_inplace_write $new_task_string; or return 5
  __tasks_inplace_write ".next_index += 1"; or return 5

  __tasks_commit_changes "Create task \"[$priority_upper] $capital_task\" with id $index" "Task \"$capital_task\" created\nID: \"$index\"\nPriority: \"$priority_upper\"" 'cyan brred green'
end

function __tasks_print
  if test -z "$argv"
    set filter '.tasks[]'
    echo 'All tasks'
  else
    set filter ".tasks[] | select(.priority == \"$argv\")"
    echo "Tasks with $argv priority"
  end

  set entries (jq -r "$filter | keys[] as \$k | .[\$k]" $tasks_file)
  set tasks_count (math (count $entries) '/ 4')

  test "$tasks_count" -eq 0; and echo -e 'NO TASKS\n'; and return

  echo ' ID | DATE        | TASK'
  for i in (seq 0 (math "$tasks_count - 1"))
    set id $entries[(math "4 * $i + 2")]
    set task $entries[(math "4 * $i + 4")]
    set date $entries[(math "4 * $i + 1")]
    set priority $entries[(math "4 * $i + 3")]

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

  set -q selected_priority; and set operations $operations "| $filter.priority = \"$selected_priority\""

  test -n "$new_task"; and set operations $operations "| $filter.task = \"$new_task\""

  set old_task (jq "$filter.task" $tasks_file)
  set old_priority (jq -r "$filter.priority" $tasks_file)

  __tasks_inplace_write $operations; or return 8
  set new_date (date '+%d/%m %H:%M')
  __tasks_inplace_write "$filter.date = \"$new_date\"" > /dev/null

  set new_task (jq "$filter.task" $tasks_file)
  set new_priority (jq -r "$filter.priority" $tasks_file)

  set output_colors 'brred'

  test "$old_task" != "$new_task"
  and set changes "Name: $old_task -> $new_task"
  and set output_colors (string join ' ' $output_colors 'cyan cyan')

  test "$old_priority" != "$new_priority"
  and set -a changes 'Priority: "'(string upper $old_priority)'" -> "'(string upper $new_priority)'"'
  and set output_colors (string join ' ' $output_colors 'green green')

  set version_control_message "Edit task #$id ("(string join ' / ' $changes)")"
  set output_message "Task #\"$id\" edited\n"(string join '\n' $changes)

  __tasks_commit_changes $version_control_message $output_message $output_colors
end

function __tasks_delete
  set key $argv[1]
  set value $argv[2]
  set filter ".tasks[] | select(.$key == $value)"

  if test "$key" = 'id'
    set version_control_message "Delete task #$value"
    set output_message "Task #\"$value\" deleted"
    set output_colors 'brred'
  else
    set affected_tasks (jq "[$filter] | length" $tasks_file)
    set unquoted_priority (echo $value | tr -d \")

    set version_control_message "Delete $affected_tasks $unquoted_priority priority task(s)"
    set output_message "\"$affected_tasks\" \"$unquoted_priority\" priority task(s) deleted"
    set output_colors 'yellow green'
  end

  __tasks_inplace_write "del($filter)"; or return 7
  __tasks_commit_changes $version_control_message $output_message $output_colors
end

function __tasks_delete_all
  echo '{"next_index": 0, "tasks": []}' | jq '.' > $tasks_file

  __tasks_commit_changes 'Delete all tasks' 'All tasks deleted'; or return 4
end

function __tasks_check_file
  test -f "$tasks_file"; or echo_err "Tasks file ($tasks_file) doesn't exist"
end

function __tasks_check_json_formatting
  test -s "$tasks_file"; or echo_err 'The tasks file is a empty file' 3; or return
  jq '.' $tasks_file > /dev/null 2> /dev/null; or echo_err 'The tasks file has JSON formatting errors' 3; or return
end

function __tasks_check_id
  set id $argv[1]

  string match -qr '^\d+$' $id; or echo_err "\"$id\" isn't a valid task ID" 6; or return

  set target (jq ".tasks[] | select(.id == $id) | has(\"task\")" $tasks_file)
  test "$target" = 'true'; or echo_err "Task #$id doesn't exist" 6
end

function __tasks_inplace_write
  set filter $argv
  set tmp_file (mktemp)

  jq "$filter" $tasks_file > $tmp_file
  if diff -q $tmp_file $tasks_file > /dev/null
    echo_err 'Nothing changes'
    return
  end

  mv $tmp_file $tasks_file
end

function __tasks_commit_changes
  set commit_message $argv[1]
  set success_message $argv[2]
  set colors $argv[3]

  g -C (dirname $tasks_file) add -A
  g -C (dirname $tasks_file) commit -qm $commit_message
  and __tasks_show_result $success_message $colors
end

function __tasks_show_result
  set format_string (echo $argv[1] | sed 's/"/%s/g; s/$/\\\n/')
  for c in (string split ' ' $argv[2])
    set -a colors_calls "(set_color $c) (set_color normal)"
  end

  eval "printf '$format_string' $colors_calls"
end

function __tasks_unset_variables
  set -e selected_priority
  set -e selected_operation
end

function __tasks_help
  echo 'Manage user day-to-day tasks

Usage:
  tasks [(-p | -i)]
  tasks [(-l | -n | -h)] [<description>]
  tasks -e
  tasks -e [(-l | -n | -h)] <id> [<description>]
  tasks -d [<id>...]
  tasks -d [(-l | -n | -h)]

Options:
  -p, --priority  Show tasks ordered by priority
  -e, --edit      Edit task
  -d, --delete    Delete task
  -l, --low       Set priority as "low"
  -n, --normal    Set priority as "normal"
  -h, --high      Set priority as "high"
  -i, --info      Show this help'
end

