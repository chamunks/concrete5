return array(
    'default-connection' => 'concrete',
    'connections' => array(
        'concrete' => array(
            'driver' => 'c5_pdo_mysql',
            'server' => 'MYSQL_SERVER',
            'database' => 'MYSQL_DATABASE',
            'username' => 'MYSQL_USERNAME',
            'password' => 'MYSQL_PASSWORD',
            'charset' => 'utf8'
        )
    )
);
