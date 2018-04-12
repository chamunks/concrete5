return array(
    'default-connection' => 'concrete',
    'connections' => array(
        'concrete' => array(
            'driver' => 'c5_pdo_mysql',
            'server' => 'DBCONF_SERVER',
            'database' => 'DBCONF_NAME',
            'username' => 'DBCONF_USERNAME',
            'password' => 'DBCONF_PASSWORD',
            'charset' => 'utf8'
        )
    )
);
