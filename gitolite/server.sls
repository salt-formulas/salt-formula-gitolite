{%- from "gitolite/map.jinja" import server with context %}
{%- if server.enabled %}

gitolite_pkgs:
  pkg.installed:
    - names: {{ server.pkgs }}

gitolite_git_user:
  user.present:
    - name: git
    - home: {{ server.home_dir }}
    - gid_from_name: true
    - shell: /bin/bash
    - system: True

gitolite_git_group:
  group.present:
    - name: git
    - system: True
    - require_in:
      - user: gitolite_git_user

gitolite_rc:
  file.managed:
    - name: {{ server.home_dir }}/.gitolite.rc
    - template: jinja
    - user: git
    - group: git
    - source: salt://gitolite/files/gitolite.rc
    - require:
      - user: gitolite_git_user

gitolite_dirs:
  file.directory:
    - names:
      - {{ server.home_dir }}/.gitolite/logs
    - user: git
    - group: git
    - makedirs: true

gitolite_conf:
  file.managed:
    - name: {{ server.home_dir }}/.gitolite/conf/gitolite.conf
    - template: jinja
    - user: git
    - group: git
    - source: salt://gitolite/files/gitolite.conf
    - makedirs: true
    - require:
      - user: gitolite_git_user

{%- for name, user in server.get('user', {}).iteritems() %}
gitolite_{{ name }}_key:
  file.managed:
    - name: {{ server.home_dir }}/.gitolite/keydir/{{ name }}.pub
    - user: git
    - group: git
    - makedirs: true
    - contents: {{ user.get('key') }}
{%- endfor %}

gitolite_setup:
  cmd.wait:
    - name: gitolite setup
    - user: git
    - workdir: {{ server.home_dir }}
    - watch:
      - file: gitolite_rc
      - file: gitolite_conf
    - require:
      - file: gitolite_dirs

{%- endif %}
