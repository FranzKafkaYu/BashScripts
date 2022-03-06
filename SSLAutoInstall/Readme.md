使用说明：

1.  使用该脚本需要将域名通过cloudflare解析

2.  使用该脚本需要获取cloudflare的Global API Key以及注册邮箱，Global API
    Key获取方式如下：

    ![](media/bda84fbc2ede834deaba1c173a932223.png)

    ![](media/d13ffd6a73f938d1037d0708e31433bf.png)

3.  该脚本所使用的证书CA方为Let‘sEncrypt，暂不支持其他CA方

4.  该脚本所使用的证书申请模式为DNS，利用DNS解析服务提供商提供的API进行解析。
5.  使用方法：bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/BashScripts/main/SSLAutoInstall/SSLAutoInstall.sh)
