vim.filetype.add {
  pattern = {
    ['.*/%.github/workflows/.*%.ya?ml'] = 'yaml.github',
  },
  extension = {
    hppm = 'cpp',
    cppm = 'cpp',
    ixx = 'cpp',
    cxxm = 'cpp',
    ccm = 'cpp',
    ['c++m'] = 'cpp',
  },
}
