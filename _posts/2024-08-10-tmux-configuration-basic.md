---
layout: post
title: 初探 Tmux 的配置 
date: 2024-08-10 13:23 +0800
---

上次记录了一些关于 [Tmux 的基本用法]()，这次来看看关于配置 tmux 的一些基本内容。tmux 和 Vim 非常类似，都可以通过众多的配置将它调教成为一个更加趁手的工具。但是搜索的时候也发现，两者的配置方式也有些许不同。本文记录一下关于 tmux configuration 的基本要点，为后续折腾打下一个基础。

首先先补充几个新学到的 tmux 命令：
- **如何在一个窗口中切换窗格的另一种方法**
    - `ctrl-b q`，按下之后每个窗格会短暂显示数字编号，在它们消失之前按下对应的数字就可以一键传送
    <div style="position: relative; padding-bottom: 56.25%; height: 0;"><iframe src="https://jumpshare.com/embed/2lsmY9vH46q2PcHjo1Rn" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe></div>
- **通过 tree mode 切换窗口和窗格**
    - `ctrl-b s (session)` 和 `ctrl-b w (window)` 是 tmux 提供的非常方便地进行 navigate 会话和窗口的功能，按下之后，屏幕上面会展示列表，可以通过上下键或者 Vim 风格的 jk 键来浏览，下方就是对应的缩略图。其中 `ctrl-b w` 会把每个 session 的所有窗口二级展开，浏览的过程中通过左右键还可以折叠和展开每个 session 的所有窗口。如果只记一个命令，后者就够了。
    <div style="position: relative; padding-bottom: 56.25%; height: 0;"><iframe src="https://jumpshare.com/embed/k1gl0WCBtxHJNMRxoONz" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe></div>
- **在一个窗口中全屏方法某一个窗格**
    - `ctrl-b z` 是 tmux 提供的 zoom-in 功能，能够将某一个窗格撑大到全屏，对于有时候需要更大空间查看的时候还是很方便的。底部的状态栏会有一个 `Z` 的标志来显示目前是放大状态。再按一次同样按键可以 unzoom。
    <div style="position: relative; padding-bottom: 56.25%; height: 0;"><iframe src="https://jumpshare.com/embed/i8uLSif9WvngcemJHdMl" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe></div>

上面这些命令都是假定以 `ctrl-b` 作为 prefix 设定的，搜索的过程中会看到有人会以 `PREFIX + binding key` 来表示某个命令组合，这是更通用的表示法。

那么如何修改 prefix 按键呢，这就是有关 tmux 的配置了。


## Tmux 的配置和 key binding

在 tmux 项目的 FAQ 里，关于[如何修改默认的 ctrl-b prefix key](https://github.com/tmux/tmux/wiki/FAQ#why-is-c-b-the-prefix-key-how-do-i-change-it)，官方提供了如下命令：

```
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

运行它们我们有两种方式，一种是 detach 出 tmux session，在我们的 shell 环境下将每一行命令交给 tmux 来运行：

```
# 在 shell 中
tmux set -g prefix C-a
tmux unbind C-b
tmux bind C-a send-prefix
```

或者在 tmux 的内部，我们就通过 tmux 的命令行模式来执行，这时候不需要前面的 `tmux`：

```
# 1. 通过 prefix : 进入命令行模式
# 2. 依次输入三条命令
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

这时候我们再试一试就会发现，ctrl-b 已经不能再进行任何操作了，prefix key 已经被我们改为了 `ctrl-a`。

这三条命令做了什么？和 shell 中执行的命令一样，tmux 也有一些内置的命令，比如 `set`, `bind`, `unbind` 就分别是设置配置项、绑定 key binding 和解绑 key binding 的命令。
- `set` 命令的 `-g` flag 是指定这是 global 配置（tmux 将配置分为 global, server, session, window 来进行细粒度控制，这里先了解即可），`prefix` 是我们要配置的 option，`C-a` 代表的是 `ctrl-a` 按键组合，这和 Vim 中的表示法是类似的。
> 注：另外，`M-a` 代表 Meta-a（windows 为 alt，mac 是 option），`S-a` 代表 Shift-a 也就是大写形式 A。
- `unbind C-b` 就是把关于默认关于 ctrl-b 的一些按键绑定给接触（tmux 是自带的一些默认配置的，这个后面也会提到）
- `bind C-a send-prefix` 是把新的 prefix key 绑定到 `send-prefix` 这个命令上，这样当我们 `prefix + ctrl-a (实际上是连按两次 ctrl-a)` 的时候，就可以输入 ctrl-a，相当于是对 prefix 的转义。

我们在上一篇中介绍到的如何激活鼠标操作 `setw -g mouse on` 也是同样的模式，我们给关于 window 的 global 配置设定了鼠标操作激活。
> 注：laixintao 在这篇[关于配置 tmux 外观的文章](https://www.kawabangga.com/posts/2477)里提到了，tmux 有多关于设置 option 命令的缩写，比如 setw 实际上是 set-window-option 的缩写。这很方便，但可能也会带来混乱。

如果进行过对 Vim 的配置，那么对 tmux 进行配置就非常好理解。比如在 Vim 中显示文件行号，也是在命令行模式下输入 `set nu`，一样的道理。


## Tmux 的配置文件，声明式配置的坑和 reset tmux 文件

我们在上面对 tmux 的配置可以说只是一次性的，如果 tmux server 重新启动的话，配置会恢复到默认状态。所以我们需要了解 tmux server 什么时候会重启，但在这之前要先理解 tmux server 和 tmux client 的概念。

当我们启动第一个 session 的时候，实际上我们启动了两个东西，tmux server 在后台帮助我们管理着一切，tmux client 是我们连上 session 的这个客户端。一个 session 可以被多个 client 进行连接，比如我们新开一个终端窗口还可以 attach 进去，然后两边的修改是实时同步的。当然实际情况下更可能的情况是服务器上的 tmux session 被不同的远程 tmux client 连接。
<div style="position: relative; padding-bottom: 56.25%; height: 0;"><iframe src="https://jumpshare.com/embed/aGrkFE6OA0YdMm83hHhf" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe></div>

只要有 tmux session 存在，即只要 shell 下 `tmux ls` 有输出，tmux server 就一直在运行着。因此想要重启 server，只有关闭掉所有的 session 才行。

接下来，为了使对配置的更改不是一次性的，我们需要把配置保存下来，让 tmux server 在启动的时候执行它们，从而不用每次都设置一遍。和 Vim 一样，我们可以通过一个配置文件来做到，tmux 的配置文件默认是 `~/.tmux.conf`。我们可以把上面三条命令写入配置文件中，当 tmux server 启动的时候会读取这个文件应用配置，这样我们的 prefix 更改就可以一直生效了。

```
# in ~/.tmux.conf

tmux set -g prefix C-a
tmux unbind C-b
tmux bind C-a send-prefix

```

需要特别注意的是，根据 tmux 的文档，配置文件只会在 tmux server 启动的时候运行：

>  It is important to note that .tmux.conf is only run when the server is started, not when a new session is created.

也就是说，如果我们加了一些配置在配置文件中，但我们仅仅只是退出再进入 tmux session，是不会看到配置被应用的。这点和 Vim 不太一样，后者退出重新进入 Vim 之后会重新运行配置文件。

因此当我们不想 kill 掉当前 session 的时候，就需要通过手动运行 source-file 命令来应用配置文件（命令可以简写为 source）：`source ~/.tmux.conf`。

**这里就来到了配置 tmux 时候的一个小坑。**

**Tmux 很 tricky 的一点在于它的配置文件是命令式的而不是声明式的。**换句话说，配置文件不是一个描述 tmux 状态的文件，它每次运行的时候仅仅是从上到下执行文件里的命令。问题的关键在于，当某个配置项没有给设置的时候，tmux 不会将它恢复到默认状态（这一点和 Vim 的配置文件表现就不一样了）。

举个例子，当我们把上面这三行加入到 `~/.tmux.conf` 中，启动 tmux server 后我们看到了配置修改。但如果我这时候将配置文件清空，然后 source 一下配置文件，会发现 prefix key 并没有回到 ctrl-b。如果在 Vim 的配置文件中，当我把显示行号的配置删除之后，再次打开 Vim 我们应该看到默认的无行号样式才对。而 tmux 中完全不是这样，实际上，之前执行过的命令被留在了 tmux 的配置里，正如[这个提问的标题所描述的一样，tmux 的配置是 cumulative 的](https://unix.stackexchange.com/questions/57641/reload-of-tmux-config-not-unbinding-keys-bind-key-is-cumulative)，配置会一直累积在那里，不会因为配置文件中没有了，效果就不存在了。如何证明配置依然存在？使用 `show -g` 命令可以查看 global 配置：

```
...
prefix C-a
...
```

我们看到 `prefix` 那一行配置依然是 `ctrl-a`。

这个特点让配置变得有些麻烦，因为理论上当运行了一个版本的 config 之后，想要撤销它们的影响，只能一个一个写出来它们的 undo 命令，然后才能恢复到原始状态，这会变得非常繁琐。

那有没有能让 tmux 重置到默认状态的方法？正如上面提到的，每次 tmux 在重启 server 的时候会加载默认的配置。可以实验一下，但显然这不是最佳的办法，仅仅为了撤销掉某个配置就关闭掉所有的 session 未免太大动干戈。

到这里你可能也想到了，既然 tmux 配置是命令式的，那么可以把所有的默认配置都先声明出来，然后在下面进行覆盖，这样当删掉新配置重新 source config 的时候，默认的配置还会应用上去，这样可以轻松地还原到一个 tmux 干净的状态。这就是上面那个问题里提问者[采取的最终的解决办法](https://unix.stackexchange.com/a/57653)：**再写一个 tmux reset 文件，里面包含了所有的 tmux 默认配置，在 `~/.tmux.conf` 文件的最开头先声明运行这个文件，下面再进行配置。**

这样的处理方法非常像是 [CSS 里的 reset](https://meyerweb.com/eric/tools/css/reset/)，通过一些配置先把浏览器自带的样式去除掉，然后再写样式规则。搜到的一个 [GitHub 项目 tmux-reset](https://github.com/hallazzang/tmux-reset) 就提供了这样一个 reset 文件。我们可以把其中的 reset 文件下载下来，然后在 `~/.tmux.conf` 中的最开头加入这行：

```
source-file {location-of-reset-file}
```

就可以保证每次 source 的时候先应用默认配置了。

到这里，我们算是理解了 tmux 配置的一些基本概念了。当然这只是 tmux 配置的冰山一角，后续就可以通过 tmux 的 manual 和网上别人的分享来学习众多的配置技巧了。


## 简单配置一下 tmux 的状态栏

这里我们来牛刀小试，通过配置修改一下 tmux 底部状态栏的颜色.

在配置文件中加入这一行：

```
set-option status-style fg=black,bg='#d7af87'
```

配置项是 `status-style`，其中 `fg` 是 foreground 颜色，也就是文字颜色，`bg` 是 background 颜色，也就是条的颜色。tmux 支持多种颜色表示法：
- 颜色关键字： black, red, green, yellow, blue, magenta, cyan, white
- 另一些亮色：bright colors, such as brightred, brightgreen, brightyellow, brightblue, brightmagenta, brightcyan
- 256-color [颜色集](https://www.ditig.com/publications/256-colors-cheat-sheet)：通过 colour0 ~ colour255 表示（注意是 colour，颜色集链接是英国网站）
- 也可以使用颜色的 hex 表示法：#000000 ~ #FFFFFF

然后 ta-da ! 我们就得到了一个稍微不一样的状态条。

<div style="position: relative; padding-bottom: 56.25%; height: 0;"><iframe src="https://jumpshare.com/embed/uATBv52Me85VLXe6QBgN" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe></div>

关于如何配置更好看、更 informative 的状态栏，之后再记录一下。
