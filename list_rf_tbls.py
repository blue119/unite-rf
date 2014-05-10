from robot.parsing import TestCaseFile
from robot.parsing import ResourceFile 
from glob import glob
import os
import sys

sep = "!~!"

def tbl_normalize(tbl):
    ibuf = ['', []]
    ibuf[0] = "%s" % (tbl.name)
    #  print("%s" % tc.name)
    for step in tbl.steps:
        ibuf[1].append("%s\t%s" % (step.keyword, '\t'.join(step.args)))
        #  print("\t%s\t%s" % (step.keyword, '\t'.join(step.args)))
    #  obuf.append(ibuf[0] + sep + sep.join(ibuf[1]))
    #  print(ibuf[0] + sep + sep.join(ibuf[1]))
    return ibuf[0] + sep + sep.join(ibuf[1]).replace('\\n', '')
    #  obuf.append(ibuf[0] + sep + sep.join(ibuf[1]))

def main(rf_dir):
    rf_ext = ['txt', 'tsv', 'html', 'rst']
    rf_files = []
    ret = []

    for path, directories, files in os.walk(rf_dir):
        rf_files += [ "%s/%s" % (path, f) for f in files if f.split('.')[-1] in rf_ext ]

    for f in rf_files[:]:
        try:
            suite = TestCaseFile(source=f).populate()
            tc_tbl = suite.testcase_table
            for tc in tc_tbl.tests:
                ret.append("test case: " + tbl_normalize(tc))
            #  ret += show_testcase(suite.testcase_table)
            #  print "TestCaseFile(%s)" % f
        except:
            res = ResourceFile(source=f).populate()
            for kw_tbl in res.keywords:
                ret.append("resource: " + tbl_normalize(kw_tbl))
            #  ret += show_resource(tbl)
            #  print "ResourceFile(%s)" % f

    #  variable_tbl = suite.variable_table
    #  keyword_tbl = suite.keyword_table
    #  import IPython; IPython.embed()
    print '\n'.join(ret)


if __name__ == '__main__':
    main(sys.argv[1])

