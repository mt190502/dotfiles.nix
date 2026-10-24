project('MyProject', 'cpp',
  version: '1.0',
  default_options: [
    'b_sanitize=undefined',
    'cpp_std=c++20',
    'debug=true',
    'optimization=1',
    'warning_level=3'
  ]
)

add_project_arguments(['-fno-omit-frame-pointer', '-fno-optimize-sibling-calls'], language: 'cpp')

# example dep
# yaml_dep = dependency('yaml-cpp', required : true, version: '>=0.7.0')

executable('MyProject',
  sources: [
    'src/main.cpp',
  ],
  # dependencies: [yaml_dep],
  install: true,
  install_dir: get_option('bindir'))

smoke_test = executable('smoke-test', 'tests/smoke.cpp')
test('smoke', smoke_test)
