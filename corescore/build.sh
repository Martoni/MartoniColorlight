# Sources from tutorial https://github.com/olofk/corescore

fusesoc library add fusesoc-cores https://github.com/fusesoc/fusesoc-cores
fusesoc library add corescore https://github.com/olofk/corescore
fusesoc core show corescore
fusesoc run --target=colorlight_5a75b corescore
