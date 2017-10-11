#!/usr/bin/python
#-*- coding:utf-8 -*-
import xlrd

#列
def getvalue_col(string,file,sheet):
    # table = xlrd.open_workbook('test_data.xls').sheet_by_name(u'Sheet1')
    table = xlrd.open_workbook(file).sheet_by_name(sheet)
    for i in range(table.ncols):
        if table.col_values(i)[0] == string:
            # print table.col_values(i)
            # print table.col_values(i)[1]
            # print type(table.col_values(i)[1])
            # print int(table.col_values(i)[1])
            return table.col_values(i)[1]

def getvalues_col(string,file,sheet):
    # table = xlrd.open_workbook('test_data.xls').sheet_by_name(u'Sheet1')
    table = xlrd.open_workbook(file).sheet_by_name(sheet)
    for i in range(table.ncols):
        if table.col_values(i)[0] == string:
            # print table.col_values(i)[1:]
            return table.col_values(i)[1:]

#行
def getvalue_row(string,file,sheet):
    # table = xlrd.open_workbook('test_data.xls').sheet_by_name(u'Sheet1')
    table = xlrd.open_workbook(file).sheet_by_name(sheet)
    for i in range(table.nrows):
        if table.row_values(i)[0] == string:
            # print table.row_values(i)
            # print table.row_values(i)[1]
            return table.row_values(i)[1]

def getvalues_row(string,file,sheet):
    # table = xlrd.open_workbook('test_data.xls').sheet_by_name(u'Sheet1')
    table = xlrd.open_workbook(file).sheet_by_name(sheet)
    for i in range(table.nrows):
        if table.row_values(i)[0] == string:
            # print table.row_values(i)[1:]
            return table.row_values(i)[1:]

if __name__ =='__main__':
    # getvalue_col('mobile','test_data.xls',u'Sheet1')
    # getvalues_col('mobile','test_data.xls',u'Sheet1')
    getvalues_row('user_name','test_data.xls',u'Sheet1')
    getvalue_row('user_name','test_data.xls',u'Sheet1')