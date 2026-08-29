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
    j2 = 'jinja',
    jinja2 = 'jinja',
    -- systemd.unit(5); path-based detection already covers */systemd/*
    service = 'systemd',
    timer = 'systemd',
    socket = 'systemd',
    target = 'systemd',
    mount = 'systemd',
    path = 'systemd',
    slice = 'systemd',
    swap = 'systemd',
    automount = 'systemd',
    link = 'systemd',
    netdev = 'systemd',
    network = 'systemd',
    nspawn = 'systemd',
    dnssd = 'systemd',
    -- Perfetto TraceConfig PBTX (protobuf text); filetype pbtxt → treesitter textproto
    pbtx = 'pbtxt',
  },
}
