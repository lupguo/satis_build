## GB-PHP包私有管理

#### 描述
基于satis构建php私有仓库包

#### 预期效果
1. 基于satis对php的包进行镜像操作，降低php包的安装网络问题，同时缩短自动化构建的时长；
2. 基于composer包对项目项目中的业务代码、工具代码，进行解耦和复用；

#### 包开发与构建以及使用过程
1. 梳理包的研发流程
    - 鼓励独立开发包，单独单元测试，通过后应用到多个项目中
    - 基于项目开发，应用到多个端的共用业务代码
2. 研发人员包如何被加入到私有库中
    - 研发初次使用，需要定义包的名称、类型、描述、作者、依赖等
    - 研发阶段主要以dev为主，即版本号为dev-master或dev-feature名称，研发可以自行配置composer进行调试
    - 研发完成后，注意打好tag标签，格式类似(v主版本.次版本.修订版本)，分支名称禁止与标签名称同类型格式（如以v1.0命名），不按标准会导致composer仓库资源构建失败
3. 整体开发新包流程细节：
    1. 研发人员本地进入开发或修改包；
    2. 研发人员针对个人开发的包进行单元检测或详细自测；
    3. 研发人员在项目(PC、WAP、APP)中，配置composer.json，先基于dev-feature分支进行检验
    4. 研发人员自测通过，对包进行tagc操作，比如v0.0.1->v0.0.2 (注意版本问题，按v主版本.次版本.修订版本格式)，同时将项目中的composer.lock、composer.json更新后提交;
        - 主版本号：当你做了不兼容的 API 修改;
        - 次版本号：当你做了向下兼容的功能性新增;
        - 修订号：当你做了向下兼容的问题修正;
    5. 服务器satis针对资源仓库进行build更新，针对composer.json有变更定期job重新构建
    6. 测试或其他同事，更新项目的最新分支，执行对应的`composer install`即可完成包的更新或者引入
    7. 如果按照包中间遇到有功能问题或者业务问题，重复1~6的更新包流程(这块强烈建议做好自检工作）
    8. 通过后，发布系统对应依赖的composer仓库也需要自动构建仓库镜像
    9. 预发布、生产发布：composer install自动与镜像仓库拉取更新
4. 私有库如何更新？
    - 服务端定期更新（job)
5. 内部私有Composer资源仓库分类：
    - 内部仓库：内部项目相关仓库存储，http://10.40.2.181:8889/inner/
    - 镜像仓库：项目依赖仓库存储，http://10.40.2.181:8889/mirror/
6. satis加包流程（服务端）
    - 添加包到satis配置：`satis add git_packages satis.json`
    - 重新build：
        - build inner源：`satis build /usr/local/satis/build/inner.json  -vvv`
        - build mirror源：`satis build /usr/local/satis/build/mirror.json -vvv`
        - build 单独资源库：`satis build --repository-url=git@gitlab.egomsl.com:dz-department/composer-packages/tools.git /usr/local/satis/build/inner.json` 

#### 开发使用：
```
    1. 在composer.json配置自己的仓库源
    2. 执行相关composer命令，比如composer require等
    // 配置一个composer.json文件
    {
        "name": "terry/test",
        "require": {
            "inner/tools" :"~0.0.1",
            "inner/business": "^0.0.4"
        },
        "repositories": [
            {
                "type": "composer",
                "url": "http://10.40.2.181:8889/inner"
            },
            {
                "type": "composer",
                "url": "http://10.40.2.181:8889/mirror"
            }
        ]
    }
    // 命令行执行composer 
    $ composer require gb/business
```

#### 运维satis服务器新增私有仓库
```
satis add git@gitlab.egomsl.com:globalegrow/php-gateway.git /usr/local/satis/build/inner.json
Your configuration file successfully updated! It's time to rebuild your repository
```

#### 运维-服务器部署
1. 安装satis: https://github.com/composer/satis
2. 结合内部项目，配置inner.json和mirror.json
3. 编辑satis-upd.sh内的satjs执行文件、logfile记录、satis配置文件路径
4. 部署satis-upd.sh的job任务，配置好自动更新间隔
```
    # 自动更新satis 仓库
    # */5 * * * *   /usr/local/satis/build/satis-upd.sh
```
5. 私有库satis服务执行satis构建日志查看：`tail -f /var/log/satis.log`

#### 问题
1. 上述build流程想好如何自动化添加、require、build ?
    目前这块主要是基于job定期更新，且不做package的全量静态化，仅做项目依赖的包做代理静态化
2. 服务器端镜像更新出问题，无法构建镜像成功
    这块主要是satis的配置文件配置错误引起，可以通过日志查看
3. 为何不使用WebUI类的管理satis配置文件
    目前开源的这块都不是很好用，暂用命令管控
