class security {
    # add a new user to place default user `pi`
    user {
        "$new_user":
            name => $new_user,
            group => 'sudo',
            password => $password;
        "pi":
            ensure => absent,
    }
}
