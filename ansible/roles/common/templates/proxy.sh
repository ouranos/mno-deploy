export http_proxy=http://{{ proxy_host }}:{{ proxy_port }}
export https_proxy=http://{{ proxy_host }}:{{ proxy_port }}
{% if proxy_ignore is defined %}
export no_proxy={{ proxy_ignore }}
{% else %}
export no_proxy="localhost,169.254.169.254"
{% endif %}
