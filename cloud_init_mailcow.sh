#cloud-config

package_upgrade: true

groups:
  - sudo: [root,skm]

users:
  - name: skm
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJrZB6JFGjrQq6QJ2mtAF0k6i05WxGl3+GomEfRoX2E4SyLMzUGCOztXBbXu/Y3HgUQd5oBQe9h6fAnb5p7uzT9i0nSMcg6SD/bLAdTr8GSH6PZlY4EnYMkz/lfuMNQJI1qOUUOyPkuSykV6pzv2RrBjafWLQTlzmhWLDvzPCWiUKEBb188DYfnASuM8b5kKH1idRl9Oa/D2yLmWLN9o2Wm45KZQaJkGoKC/r7KQ8RVa94qUbgYdKxvF3d4SYUkRzrv3J8umtdWJyRTtzSDjHBd0kPfMHAz1Ti3EYRdtrbviaA8rBteQIwNy6hj1R70taSmIa4qj1phOZV4emD4Ym/0D0XXhyiiupukMw3lj2wwuTaHNcM9b5BGH1IQHeaxsGF9aFy15yNnMGAOnRlYePAdhoZB3S10VCOi+doIGk/oEq457Lw7SUgo1GdV3OafP/hiMAeSxQfRj4dVSh+gpsXPVBdeEypQhAt9QRqpTOC+rpmJo8pWiAUNnaH/RJWFM0= skm@MacBook-Pro-Kirill.local

packages:
    - vim
    - whois
    - curl
    - fail2ban
    - tldr
    - net-tools
    - zsh
    - git
    - unison

write_files:
  - path: /etc/fail2ban/jail.local
    content: |
      [sshd]
      enabled = true
      maxretry = 6
      findtime = 1h
      bantime = 1d
      ignoreip = 127.0.0.1/8 23.34.45.56
      destemail = kirill@sukharev.ru

runcmd:
    - mkdir /root/mail_volumes
    # - mount -t nfs 195.91.221.156:/volume2/server_data /root/mail_volumes
    # - echo '195.91.221.156:/volume2/server_data /root/mail_volumes nfs rw 0 0' >> /etc/fstab
    - curl -sSL https://get.docker.com | sh
    - usermod -aG docker skm

    - systemctl enable docker
    - systemctl start docker

    - curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    - chmod +x /usr/local/bin/docker-compose
    - ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    - systemctl enable fail2ban
    - systemctl start fail2ban
    
    - ufw allow 22
    - ufw allow 25
    - ufw allow 80
    - ufw allow 110
    - ufw allow 143
    - ufw allow 443
    - ufw allow 465
    - ufw allow 587
    - ufw allow 993
    - ufw allow 995
    - ufw allow 4190

    - ufw enable 
    - cd /opt && git clone https://github.com/Soliton80/mailcow-dockerized.git
    - cd /opt && git clone https://github.com/imapsync/imapsync.git

    - chsh -s /bin/zsh skm
    - su - skm -c "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    - su - skm -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    - su - skm -c "git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    - su - skm -c "sed -i 's/plugins=(git)/plugins=(vi-mode git zsh-syntax-highlighting zsh-autosuggestions sudo history)/' ~/.zshrc"
    - su - skm -c "source ~/.zshrc"

