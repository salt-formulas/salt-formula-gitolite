{%- if pillar.gitolite is defined %}
include:
{%- if pillar.gitolite.server is defined %}
- gitolite.server
{%- endif %}
{%- endif %}
