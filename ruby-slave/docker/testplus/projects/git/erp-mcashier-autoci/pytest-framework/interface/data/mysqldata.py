#!/usr/bin/python
#-*- coding:utf-8 -*-
import torndb,time,yaml,os
from interface.testmain import *


data = yaml.load(file(os.path.dirname(__file__)+'/database.yml'))

# env = 'STG'
env = getenv()

def db():
    # db = torndb.Connection("192.168.28.218", "ironhide_test", user="ironhide", password="ironhide_staging123!")
    DB = torndb.Connection(data[env]['mysql']['host'], data[env]['mysql']['database'], user=data[env]['mysql']['username'], password=data[env]['mysql']['password'])
    return DB

db = db()

def resetuser(username):
    sql = 'UPDATE users SET mobile = \'%s\' WHERE user_name = \'%s\'' % (str(int(time.time())), username)
    db.execute(sql)
    db.close()

def resetname(username):
    sql = 'UPDATE users SET user_name = \'%s\' WHERE user_name = \'%s\'' % (username + str(int(time.time())), username)
    db.execute(sql)
    db.close()

def getNotificationId(userid):
    sql = 'SELECT id FROM notifications WHERE to_user_id = \'%s\'' % userid
    notificationsId = db.query(sql)[0]['id']
    db.close()
    return notificationsId

def getarticleId(userid,status = 1):
    sql = 'SELECT id FROM articles WHERE user_id = \'%s\' and status = \'%s\'' % (userid,status)
    articles = db.query(sql)
    if articles != []:
        articleId = articles[-1]['id']
        db.close()
        return articleId
    return articles

def getcommentId(userid,prouserid,status = 1):
    for articleId in getarticlesId(prouserid,status):
        sql = 'SELECT id FROM comments WHERE user_id = \'%s\' and item_id = \'%s\' and item_type = 1'% (userid,articleId)
        comments_id = db.query(sql)
        if comments_id != []:
            comment_id = db.query(sql)[-1]['id']
            break
        else:
            comment_id = []
    db.close()
    return comment_id

def getcommentId_atuser(atuserid):
    sql = 'SELECT id FROM comments WHERE at_user_id = \'%s\' '% atuserid
    comments_id = db.query(sql)
    if comments_id != []:
        comment_id = db.query(sql)[-1]['id']
    else:
        comment_id = []
    db.close()
    return comment_id

def getarticlesId(userid,status = 1):
    sql = 'SELECT id FROM articles WHERE user_id = \'%s\' and status = \'%s\'' % (userid,status)
    b = []
    articlesId = db.query(sql)
    for i in range(0,len(articlesId)):
        articleId = articlesId[i]['id']
        b.append(articleId)
    db.close()
    return b
    # return articlesId

def getrepliearticleId(comment_id):
    sql = 'SELECT item_id FROM comments WHERE id = \'%s\'' % comment_id
    articleId = db.query(sql)[0]['item_id']
    db.close()
    return articleId

def getCommentsArticleId(comment_count):
    sql = 'SELECT id FROM articles WHERE comment_count > \'%s\'' % comment_count
    articleId = db.query(sql)[-1]['id']
    db.close()
    return articleId


def getanchorId(feature_id):
    sql = 'SELECT id FROM feature_anchors WHERE feature_id = \'%s\'' % feature_id
    anchorId = db.query(sql)[-1]['id']
    db.close()
    return anchorId

def getanchorname(anchorId):
    sql = 'SELECT name FROM feature_anchors WHERE id = \'%s\'' % anchorId
    anchorname = db.query(sql)[-1]['name']
    db.close()
    return anchorname


def getquestionId(userId):
    sql = 'SELECT id FROM questions WHERE user_id = \'%s\'' % userId
    questions = db.query(sql)
    if questions != []:
        questionId = questions[-1]['id']
        db.close()
        return questionId
    db.close()
    return questions

def getanswersId(userId):
    sql = 'SELECT id FROM answers WHERE user_id = \'%s\'' % userId
    answersIds = db.query(sql)
    if answersIds != []:
        answersId = answersIds[-1]['id']
        db.close()
        return answersId
    db.close()
    return answersIds

def getanswerQuestionId(answerId):
    sql = 'SELECT question_id FROM answers WHERE id = \'%s\'' % answerId
    questions = db.query(sql)
    if questions != []:
        questionId = db.query(sql)[-1]['question_id']
        db.close()
        return questionId
    db.close()
    return questions

def getanswersCommentId(answersId,userId):
    sql = 'SELECT id FROM comments WHERE item_id = \'%s\'and user_id = \'%s\'' % (answersId,userId)
    commentIds = db.query(sql)
    if commentIds != []:
        commentId = db.query(sql)[-1]['id']
        db.close()
        return commentId
    db.close()
    return commentIds



def getNoAnswerQuestions(quserId,auserId):
    sql = 'SELECT id FROM questions WHERE user_id = \'%s\'' % quserId
    questionsId = db.query(sql)
    if questionsId != []:
        b = []
        for i in range(0,len(questionsId)):
            questionId = questionsId[i]['id']
            sql = 'SELECT id FROM answers WHERE user_id = \'%s\' and question_id = \'%s\'' % (auserId,questionId)
            answerId = db.query(sql)
            if answerId == []:
                b.append(questionsId[i]['id'])
            db.close()
            if b != []:
                return b[-1]
        return b


def getAnswerQuestions(quserId,auserId):
    sql = 'SELECT id FROM questions WHERE user_id = \'%s\'' % quserId
    questionsId = db.query(sql)
    if questionsId != []:
        b = []
        for i in range(0,len(questionsId)):
            questionId = questionsId[i]['id']
            sql = 'SELECT id FROM answers WHERE user_id = \'%s\' and question_id = \'%s\'' % (auserId,questionId)
            answerId = db.query(sql)
            if answerId != []:
                b.append(questionsId[i]['id'])
            db.close()
            if b != []:
                return b[-1]
        return b

def getfocus_count(questionId=None,topicsId=None,userId=None):
    if questionId != None:
        sql = 'SELECT focus_count FROM questions WHERE id = \'%s\'' % questionId
    elif topicsId != None:
        sql = 'SELECT focus_count FROM topics WHERE id = \'%s\'' % topicsId
    elif userId != None:
        sql = 'SELECT focus_count FROM users WHERE id = \'%s\'' % userId
    focus_count = db.query(sql)[0]['focus_count']
    db.close()
    return focus_count

def getarticleId_commentId(commentId):
    sql = 'SELECT item_id FROM comments WHERE id = \'%s\'' % commentId
    articleId = db.query(sql)[-1]['item_id']
    db.close()
    return articleId


def getUsernamebyopenid(open_id):
    sql = 'SELECT user_id FROM user_socials WHERE open_id = \'%s\'' % open_id
    user_id = db.query(sql)[-1]['user_id']
    sql = 'SELECT user_name FROM users WHERE id = \'%s\'' % user_id
    username = db.query(sql)[-1]['user_name']
    db.close()
    return username

def getlinkname(link_id):
    sql = 'SELECT name FROM links WHERE id = \'%s\'' % link_id
    linknames = db.query(sql)
    if linknames != []:
        linkname = db.query(sql)[0]['name']
        db.close()
        return linkname
    db.close()
    return linknames

def getarticle_off(user_id):
    sql = 'SELECT id FROM articles WHERE user_id = \'%s\' and status = -1' % user_id
    articles = db.query(sql)
    if articles != []:
        article_off = db.query(sql)[-1]['id']
        db.close()
        return article_off
    db.close()
    return articles

def getdraftid(user_id,status):
    sql = 'SELECT id FROM drafts WHERE user_id = \'%s\' and status = \'%s\'' % (user_id,status)
    drafts = db.query(sql)
    if drafts != []:
        draftid = db.query(sql)[-1]['id']
        db.close()
        return draftid
    db.close()
    return drafts

def getdraftStatus(post_id):
    sql = 'SELECT status FROM drafts WHERE id = \'%s\'' % post_id
    statusId = db.query(sql)
    if statusId != []:
        status = db.query(sql)[-1]['status']
        db.close()
        return status
    db.close()
    return statusId

def getarticleidByDraft(draft_id):
    sql = 'SELECT article_id FROM drafts WHERE id = \'%s\'' % draft_id
    articles = db.query(sql)
    if articles != []:
        article_id = db.query(sql)[-1]['article_id']
        db.close()
        return article_id
    db.close()
    return articles


def getFeatureName(feature_id):
    sql = 'SELECT title FROM features WHERE id = \'%s\'' % feature_id
    featureName = db.query(sql)[0]['title']
    db.close()
    return featureName

def getarticle_status(articleId):
    sql = 'SELECT status FROM articles WHERE id = \'%s\'' % articleId
    status = db.query(sql)[-1]['status']
    db.close()
    return status


def getUsernamebyUserid(user_id):
    sql = 'SELECT user_name FROM users WHERE id = \'%s\'' % user_id
    usernames = db.query(sql)
    if usernames != []:
        username = db.query(sql)[0]['user_name']
        db.close()
        return username
    db.close()
    return usernames

def getApplyId(status,userid):
    sql = 'SELECT id FROM apply_authors WHERE status = \'%s\' and user_id = \'%s\'' % (status,userid)
    applyid = db.query(sql)[0]['id']
    db.close()
    return applyid

def resetRole(user_id):
    sql = 'UPDATE users SET role_id = \'%s\' WHERE id = \'%s\'' % (4, user_id)
    db.execute(sql)
    sql = "delete from apply_authors where user_id = \'%s\'" % user_id
    db.execute(sql)

def getApplyStatus(userid):
    sql = 'SELECT status FROM apply_authors WHERE user_id = \'%s\'' % userid
    status = db.query(sql)[0]['status']
    db.close()
    return status



# print getApplyId(0,213)
# print getUsernamebyUserid(213)
# print getarticleId(23)
# print getcommentId(28,23)
# print getarticlesId(8)
# print getrepliearticleId(getcommentId(222,8))

# print getCommentsArticleId(10)
# print getanswersCommentId(28,23)
# print getanswersId(23)
# print getNoAnswerQuestions(23)
# print getAnswerQuestions(23)
# print getfocus_count(questionId=253)
# db()
# print getcommentId(23,7,-1)

# print getNoAnswerQuestions(15,15)
# print getUsernamebyopenid('oT5idwktiWHoblD9FsXY-QUevF4Y')
# import sys
# reload(sys)
# sys.setdefaultencoding( "utf-8" )
#
# print type(str(getlinkname(46)))

# print getarticle_off(7)
# print getcommentId(23,7,-1)
# print getFeatureName(1)