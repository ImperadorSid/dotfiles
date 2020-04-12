function tasks -d "Manage tasks"
  set -g tasks_file ~/Documents/Books/Others/tasks.json
  if not __tasks_check_file; return 1; end

  set options 'p/priority' 'l/low' 'n/normal' 'h/high' 'e/edit' 'd/delete' 'y/yes'
  argparse -n 'Tasks' -x 'p,e,d' -x 'p,l,n,h' -x 'p,y' -X 2 $options -- $argv
  if test $status -ne 0; return 2; end

  if set -q _flag_low; set -g selected_priority 'low'; end
  if set -q _flag_normal; set -g selected_priority 'normal'; end
  if set -q _flag_high; set -g selected_priority 'high'; end

  if set -q _flag_edit; set -g selected_operation 'edit'; end
  if set -q _flag_delete; set -g selected_operation 'delete'; end
  
  __tasks_print_all
  if set -q _flag_priority
    __tasks_print_category
  end
    
  #set -e tasks_file
  #set -e selected_priority
  return
end

function __tasks_print_all
  set tasks_count (jq '.tasks | length' $tasks_file)

  for i in (seq 0 (math "$tasks_count - 1"))
    set id (__tasks_get_task $i "id")
    set task (__tasks_get_task $i "task")
    set date (__tasks_get_task $i "date")
    set priority (__tasks_get_task $i "priority")

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

  echo -e "\n  TOTAL: $tasks_count tarefas"
end

function __tasks_print_category

end

function __tasks_get_task
  set order $argv[1]
  set field $argv[2]

  jq -r ".tasks[$order].$field" $tasks_file
end

function __tasks_check_file
  if test ! -f $tasks_file
    echo "Tasks file ($tasks_file) doesn't exist"
    set -e tasks_file
    return 1
  end
  return 0
end

