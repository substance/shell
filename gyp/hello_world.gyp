{
    "includes": [
        "common.gypi"
    ],
    "variables": {
        "root": "..",
        "src": "../src",
        "include": "../include"
    },
    "targets": [
        {
            "target_name": "mylib",
            "product_name": "mylib",
            "type": "static_library",
            "sources": [
                "<(src)/mylib/mylib.cpp"
            ],
            "include_dirs": [
                "<(include)/mylib"
            ],
            'direct_dependent_settings': {
              'include_dirs': [ '<(include)/' ],
            }
        },
        {
            "target_name": "myapp",
            "type": "executable",
            "sources": [
                "<(src)/myapp/myapp.cpp"
            ],
            "include_dirs": [
                "<(include)"
            ],
            "dependencies": [
                "mylib"
            ]
        }
    ]
}
