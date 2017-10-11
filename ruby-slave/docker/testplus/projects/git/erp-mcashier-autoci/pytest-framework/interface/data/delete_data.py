#!/usr/bin/python
#-*- coding:utf-8 -*-
import torndb,time,yaml,os
from mysqldata import *


def delete_feature_by_title(title):
    sql = "delete from  feature_anchor_relations where feature_anchor_id in (select A.id from feature_anchors A inner join features B on A.feature_id=B.id where B.title=\'%s\')" % title
    db.execute(sql)
    sql = "delete from banners where target_type=3 and target_id in (select id from features where title=\'%s\')" % title
    db.execute(sql)
    sql = "delete from posts where post_type=3 and post_id in (select id from features where title=\'%s\')" % title
    db.execute(sql)
    sql = "delete from feature_anchors where feature_id in (select id from features where title=\'%s\')" % title
    db.execute(sql)
    sql = "delete from features where title=\'%s\'" % title
    db.execute(sql)



def delete_article_by_id(article_id):
    sql = "delete from likes where item_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from follows where item_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from favorites where item_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from notifications where model_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from user_histories where model_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    # sql = "delete from banners where target_type=1 and item_id=\'%s\'" % article_id
    # db.execute(sql)
    sql = "delete from  feature_anchor_relations where item_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from  topic_relations where item_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from comments where item_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from attachments where item_type=1 and item_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from posts where post_type=1 and post_id=\'%s\'" % article_id
    db.execute(sql)
    sql = "delete from articles where id=\'%s\'" % article_id
    db.execute(sql)




def delete_answers_by_answer_id(answer_id):
    sql = "delete from likes where item_type=5 and item_id=\'%s\'" % answer_id
    db.execute(sql)
    # sql = "delete from banners where target_type=5 and target_id==\'%s\'" % answer_id
    # db.execute(sql)
    sql = "delete from favorites where item_type=5 and item_id=\'%s\'" % answer_id
    db.execute(sql)
    sql = "delete from notifications where model_type=5 and item_id=\'%s\'" % answer_id
    db.execute(sql)
    sql = "delete from user_histories where model_type=5 and item_id=\'%s\'" % answer_id
    db.execute(sql)
    sql = "delete from comments where item_type=5 and item_id=\'%s\'" % answer_id
    db.execute(sql)
    sql = "delete from attachments where item_type=5 and item_id=\'%s\'" % answer_id
    db.execute(sql)
    sql = "delete from posts where post_type=5 and post_id=\'%s\'" % answer_id
    db.execute(sql)
    sql = "delete from answers where id=\'%s\'" % answer_id
    topics = db.execute(sql)

def get_answers_by_question_id(question_id):
    sql = 'SELECT id FROM answers WHERE question_id = \'%s\'' % question_id
    answersIds = db.query(sql)
    db.close()
    return answersIds



def delete_questions_by_question_id(question_id):
    answers = get_answers_by_question_id(question_id)
    if answers != []:
        for answer in answers:
            delete_answers_by_answer_id(answer['id'])
    sql = "delete from feature_anchor_relations where item_type=4 and item_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from topic_relations where item_type=4 and item_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from user_histories where item_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from notifications where model_type=4 and item_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from follows where item_type=4 and item_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from banners where target_type=4 and target_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from attachments where item_type=4 and item_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from posts where post_type=4 and post_id=\'%s\'" % question_id
    db.execute(sql)
    sql = "delete from questions where id=\'%s\'" % question_id
    topics = db.execute(sql)


# delete_feature_by_title('专题16101801')
# delete_article_by_id(333)
# delete_answers_by_answer_id(604)
# delete_questions_by_question_id(834)
