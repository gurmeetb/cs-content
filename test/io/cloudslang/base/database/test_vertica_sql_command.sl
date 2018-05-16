namespace: io.cloudslang.base.database

imports:
    db: io.cloudslang.base.database
    strings: io.cloudslang.base.strings
    
flow:
  name: test_vertica_sql_command

  inputs:
    - db_server_name
    - db_port:
        required: false
        default: "5433"
    - username
    - password:
        sensitive: true
    - database_name

  outputs:
    - return_result
    - output_text

  workflow:
    - sql_create_table:
        do:
          io.cloudslang.base.database.sql_command:
            - db_server_name: ${db_server_name}
            - db_port: ${db_port}
            - db_type: Vertica
            - username: ${username}
            - password: ${password}
            - database_name: ${database_name}
            - command: 'CREATE TABLE TestCsTickStore (ts TIMESTAMP, symbol VARCHAR(8), bid FLOAT);'
            - trust_all_roots: 'true'
        publish:
          - output_text: ${output_text}
          - return_result: ${return_result}
        navigate:
          - SUCCESS: sql_insert_row
          - FAILURE: CREATE_STACK_FAILURE

    - sql_insert_row:
        do:
          io.cloudslang.base.database.sql_command:
            - db_server_name: ${db_server_name}
            - db_port: ${db_port}
            - db_type: Vertica
            - username: ${username}
            - password: ${password}
            - database_name: ${database_name}
            - command: "INSERT INTO TestCsTickStore VALUES ('2018-01-01 03:00:00', 'XYZ', 10.0);"
            - trust_all_roots: 'true'
        publish:
          - output_text: ${output_text}
          - return_result: ${return_result}
        navigate:
          - SUCCESS: sql_select_count
          - FAILURE: CREATE_STACK_FAILURE

    - sql_select_count:
        do:
          io.cloudslang.base.database.sql_command:
            - db_server_name: ${db_server_name}
            - db_port: ${db_port}
            - db_type: Vertica
            - username: ${username}
            - password: ${password}
            - database_name: ${database_name}
            - command: 'SELECT COUNT(*) FROM TestCsTickStore;'
            - trust_all_roots: 'true'
        publish:
          - output_text: ${output_text}
          - return_result: ${return_result}
        navigate:
          - SUCCESS: sql_drop_table
          - FAILURE: CREATE_STACK_FAILURE
          
    - sql_drop_table:
        do:
          io.cloudslang.base.database.sql_command:
            - db_server_name: ${db_server_name}
            - db_port: ${db_port}
            - db_type: Vertica
            - username: ${username}
            - password: ${password}
            - database_name: ${database_name}
            - command: 'DROP TABLE TestCsTickStore;'
            - trust_all_roots: 'true'
        publish:
          - output_text: ${output_text}
          - return_result: ${return_result}
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: CREATE_STACK_FAILURE
              
  results:
    - SUCCESS
    - CREATE_STACK_FAILURE
