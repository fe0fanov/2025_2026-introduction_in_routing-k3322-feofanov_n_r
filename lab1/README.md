# Лабораторная работа №1 "Установка ContainerLab и развертывание тестовой сети связи"

University: ITMO University
Faculty: FICT
Course: Introduction in routing
Year: 2025/2026
Group: K3322
Author: Feofanov Nikita Romanovich
Lab: Lab1
Date of create: 8.10.2025
Date of finished: 13.10.2025

## Схема сети

На рисунке ниже представлена схема сети, нарисованная в draw.io

рисунок

## Установка ContainerLab

Для работы инструмента предварительно необходимо было установить `Docker`, `vrnetlab` и утилита `make`.  
В папку /vrnetlab/mikrotik/routeros был загружен файл chr-6.47.9.vmdk и собран docker образ через:
```
make docker-image
```
Сам ContainerLab был установлен через команду:
```
bash -c "$(curl -sL https://get.containerlab.dev)"
```
## Создание базовой топологии и сети управления

Был создан файл `lab1.clab.yaml`, в котором была создана базовая топология и задана сеть управления.

Далее был выполнен деплой через команду `clab deploy -t lab1.clab.yaml`

Затем был построен граф топологии командой `clab graph -t lab1.clab.yaml`

## Настройка VLAN, DHCP, написание конфигов

### Настройка роутера R01

Создаем два VLAN'а на ether2 (важно, что Ether1 выделяется под ether0, поэтому начинаем брать интерфейсы с ether2):
```
add name=vlan10 vlan-id=10 interface=ether2
add name=vlan20 vlan-id=20 interface=ether2
```
Задаем ip адрес внутри каждого из VLAN:
```
add address=10.10.0.1/24 interface=vlan10
add address=10.20.0.1/24 interface=vlan20
```
Затем задаём пул адресов для каждого VLAN и настраиваем DHCP сервера:
```
add name=pool10 ranges=10.10.0.10-10.10.0.254
add name=pool20 ranges=10.20.0.10-10.20.0.254

add address-pool=pool10 disabled=no interface=vlan10 name=dhcp-server10
add address-pool=pool20 disabled=no interface=vlan20 name=dhcp-server20

add address=10.10.0.0/24 gateway=10.10.0.1
add address=10.20.0.0/24 gateway=10.20.0.1
```
Также в условии задания просили настроить имена устройств, сменить логины и пароли. Делаем это следующими командами:
```
add name=fe0fanov password=1234 group=full
remove admin

set name=R01
```

### Настройка свича SW01

Так как через свич идут 2 VLAN'а, то необходимо фильтровать пакеты. Делается это с помощью мостов.  
Настраиваем интерфейс моста, включаем vlan-filtering и указываем имя моста для каждого VLAN:
```
add name=bridge1 vlan-filtering=yes

add name=vlan10 vlan-id=10 interface=bridge1
add name=vlan20 vlan-id=20 interface=bridge1
```
Затем указываем все порты устройства:
```
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
add bridge=bridge1 interface=ether4
```
Далее указываем id VLAN и в tagged сам мост и trunk порты:
```
add bridge=bridge1 tagged=bridge1,ether2,ether3 vlan-ids=10
add bridge=bridge1 tagged=bridge1,ether2,ether4 vlan-ids=20
```
Настраиваем ip:
```
add address=10.10.0.2/24 interface=vlan10
add address=10.20.0.2/24 interface=vlan20
```
Далее в конфиге настройка имени устройства и смена логина и пароля, аналогичная роутеру, поэтому заново писать её в отчёт не буду.

### Настройка SW02.01 и .02

Рассмотрим на примере SW02.01. Настраиваем интерфейса моста и VLAN:
```
add name=bridge1
add name=vlan10 vlan-id=10 interface=bridge1
```
Настраиваем порты:
```
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3 pvid=10
```
Настраиваем trunk- и access- порты (tagged для trunk, untagged для access) и указываем id VLAN:
```
add bridge=bridge1 tagged=bridge1,ether2 untagged=ether3 vlan-ids=10
```
Настраиваем ip:
```
add address=10.10.0.3/24 interface=vlan10
```
Далее аналогичная предыдущим устройствам настройка имени и смена логина и пароля. Конфиг для SW02.02 идентичный, меняется только id VLAN.

### Настройка PC
Для PC изначально планировалось тоже написать конфиги, однако в итоге оказалось, что по какой-то причине образ Ubuntu на них был установлен максимально примитивный без утилит для работы с `ip`, `udhcpc` и даже `ping`.

Поэтому было решено вручную зайти в каждый ПК, установить необходимые утилиты и затем настроить. Зайти в компьютеры можно с помощью команды:
```
docker exec -it <name> sh
```
Устанавливаем необходимые утилиыты:
```
apt-get update
apt-get install -y iproute2 busybox
apt-get install udhcpc
apt-get install -y iputils-ping
```
Затем для каждого ПК настраиваем VLAN и запрашиваем ip у сервера. Ниже пример для PC1:
```
ip link add link eth1 name vlan10 type vlan id 10
ip link set vlan10 up
udhcpc -i vlan10
```
И финально настраивам маршрут для связи компьютеров между друг другом:
```
ip route add 10.20.0.0/24 via 10.10.0.1 dev vlan10
```

## Проверка работоспособности системы

Зайдём внутрь роутера через команду `ssh username@clab-lab1-R01.TEST`
Проверим пинг с роутера:

Проверим доступность компьютеров между собой:

## Заключение
В ходе работы были создана трёхуровневая сеть для классического предприятия. Все устройства успешно соединены, были настроены два VLAN'а и DHCP серверы внутри них для раздачи ip компьютерам.

Лабораторная работа успешно выполнена
