#!/usr/bin/python
#-*- coding:utf-8 -*-
from appium import webdriver
import time

desired_caps = {}
desired_caps['platformName'] = 'Android'
desired_caps['platformVersion'] = '6.0 Marshmallow'
desired_caps['deviceName'] = 'Android Emulator'
desired_caps['appPackage'] = 'com.istuary.ironhide'
desired_caps['appActivity'] = '.view.splash.SplashActivity'

driver = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)

time.sleep(10)
driver.find_elements_by_class_name('android.widget.RelativeLayout')[0].click()
time.sleep(2)
driver.find_elements_by_class_name('android.widget.LinearLayout')[0].click()
time.sleep(2)
driver.find_element_by_id('com.istuary.ironhide:id/input_phone').send_keys('13540108163')
time.sleep(2)
driver.find_element_by_id('com.istuary.ironhide:id/input_pwd').send_keys('123456')
time.sleep(2)
driver.find_element_by_id('com.istuary.ironhide:id/button').click()
time.sleep(2)



driver.quit()
