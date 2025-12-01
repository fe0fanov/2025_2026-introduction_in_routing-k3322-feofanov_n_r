University: [ITMO University](https://itmo.ru/ru/)<br />
Faculty: [FICT](https://fict.itmo.ru)<br />
Course: [Introduction in routing](https://github.com/itmo-ict-faculty/introduction-in-routing)<br />
Year: 2025/2026<br />
Group: K3322<br />
Author: Feofanov Nikita<br />
Lab: Lab3<br />
Date of create: 25.11.2025<br />
Date of finished: 25.11.2025<br />

# Задание

Вам необходимо сделать IP/MPLS сеть связи для "RogaIKopita Games" изображенную на рисунке 1 в ContainerLab. Необходимо создать все устройства указанные на схеме и соединения между ними.

- Помимо этого вам необходимо настроить IP адреса на интерфейсах.
- Настроить OSPF и MPLS.
- Настроить EoMPLS.
- Назначить адресацию на контейнеры, связанные между собой EoMPLS.
- Настроить имена устройств, сменить логины и пароли.

# Схема

Схема в draw.io:

<img src="images/graph.png">

Схема ContainerLab:

<img src="images/graph_clab.png">

# yaml-конфиг

В конфигурации сети 6 роутеров, компьютер, а также SGI-PRISM использует образ компьютера.

Сеть управления: 172.16.16.0/24.

<img src="images/table.png">

# Конфиги устройств

## Роутеры

1) Прописываем интерфейсы на портах по нарисованной схеме, а в роутерах NY и SPB ещё и dhcp-сервера.
2) Настраиваем динамическую маршрутизацию osfp:
- /interface bridge add name=loopback (loopback хорош тем, что это интерфейс с IP-адресом, который сам по себе никогда не упадёт без вмешательства)
- /ip address interface=loopback
- /routing ospf instance (указываем в router-id адрес loopback интерфейса)
- /routing ospf area (достаточно одной зоны для всех устройств)
- /routing ospf network (пишем имя зоны и все физические подключения)
3) Настройка MPLS:
- /mpls ldp (для transport-address тоже удобно использовать адрес loopback)
- /mpls ldp advertise-filter & accept-filter (Ограничиваем, какие префиксы сетей будут получать ярлыки)
/mpls ldp interface (просто указываем все интерфейсы роутеров)
4) Настраиваем EoMPLS (на NY и SPB роутерах)
- /interface bridge (VPN, который соединяем с интерфейсом vpls и портом)
- /interface vpls (remote-peer: ip loopback-интерфейса другого роутера)
- /interface bridge port

## Компьютеры

Аналогично предыдущим лабораторным запрашивают ip у dhcp-сервера.

# Результаты

## 1: OSPF

Проверка динамической маршрутизации:

<img src="images/ospf1.png">
<img src="images/ospf2.png">
<img src="images/ospf3.png">
<img src="images/ospf4.png">
<img src="images/ospf5.png">
<img src="images/ospf6.png">

Видно, что всё настроено динамически.

## 2: MPLS

<img src="images/mpls1.png">
<img src="images/mpls2.png">
<img src="images/mpls3.png">
<img src="images/mpls4.png">
<img src="images/mpls5.png">
<img src="images/mpls6.png">

С фильтрацией:

<img src="images/mpls_filtered.png">

## 3: VPLS

<img src="images/vpls1.png">
<img src="images/vpls2.png">

## Соединение компьютеров

<img src="images/ping_pc.png">

# Заключение

Была настроена динамическая маршрутизация через OSFP, поверх которой положена сеть MPLS, и был проведён туннель VPLS между роутерами NY и SPB.

Лабораторная работа успешно выполнена!
