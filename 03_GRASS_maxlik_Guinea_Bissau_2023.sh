#!/bin/sh
# 1. Import data
# listing the files

# g.mapset location=Guinea_Bissau_2023 mapset=PERMANENT

g.list rast
# importing the image subset with 7 Landsat bands and display the raster map
r.import input=/Users/polinalemenkova/grassdata/Guinea_Bissau_2023/LC09_L2SP_204052_20230507_20230509_02_T1_SR_B1.TIF output=L8_2023_01 extent=region resolution=region
r.import input=/Users/polinalemenkova/grassdata/Guinea_Bissau_2023/LC09_L2SP_204052_20230507_20230509_02_T1_SR_B2.TIF output=L8_2023_02 extent=region resolution=region
r.import input=/Users/polinalemenkova/grassdata/Guinea_Bissau_2023/LC09_L2SP_204052_20230507_20230509_02_T1_SR_B3.TIF output=L8_2023_03 extent=region resolution=region
r.import input=/Users/polinalemenkova/grassdata/Guinea_Bissau_2023/LC09_L2SP_204052_20230507_20230509_02_T1_SR_B4.TIF output=L8_2023_04 extent=region resolution=region
r.import input=/Users/polinalemenkova/grassdata/Guinea_Bissau_2023/LC09_L2SP_204052_20230507_20230509_02_T1_SR_B5.TIF output=L8_2023_05 extent=region resolution=region
r.import input=/Users/polinalemenkova/grassdata/Guinea_Bissau_2023/LC09_L2SP_204052_20230507_20230509_02_T1_SR_B6.TIF output=L8_2023_06 extent=region resolution=region
r.import input=/Users/polinalemenkova/grassdata/Guinea_Bissau_2023/LC09_L2SP_204052_20230507_20230509_02_T1_SR_B7.TIF output=L8_2023_07 extent=region resolution=region
#
g.list rast
#
# grouping data by i.group
# Set computational region to match the scene
g.region raster=L8_2023_01 -p
# projection: 1 (UTM)
# zone:       28
# datum:      wgs84
# ellipsoid:  wgs84
# north:      1394715
# south:      1161885
# west:       305685
# east:       533715
# nsres:      30
# ewres:      30
# rows:       7761
# cols:       7601
# cells:      58991361
# store VIZ, NIR, MIR into group/subgroup (leaving out TIR)
i.group group=L8_2023 subgroup=res_30m \
  input=L8_2023_01,L8_2023_02,L8_2023_03,L8_2023_04,L8_2023_05,L8_2023_06,L8_2023_07
#
# 4. Clustering: generating signature file and report using k-means clustering algorithm
i.cluster group=L8_2023 subgroup=res_30m \
  signaturefile=cluster_L8_2023 \
  classes=12 reportfile=rep_clust_L8_2023.txt --overwrite
# 5. Classification by i.maxlik module
#
i.maxlik group=L8_2023 subgroup=res_30m \
  signaturefile=cluster_L8_2023 \
  output=L8_2023_cluster_classes reject=L8_2023_cluster_reject --overwrite
#
# 6. Mapping
d.mon wx0
g.region raster=L8_2023_cluster_classes -p
r.colors L8_2023_cluster_classes color=roygbiv -e
d.rast L8_2023_cluster_classes
d.legend raster=L8_2023_cluster_classes title="2023 May 07" title_fontsize=14 font="Helvetica" fontsize=12 bgcolor=white border_color=white
d.out.file output=Guinea_Bissau_2023 format=jpg --overwrite
#
d.mon wx1
g.region raster=L8_2023_cluster_classes -p
r.colors L8_2023_cluster_reject color=aspectcolr -e
d.rast L8_2023_cluster_reject
d.legend raster=L8_2023_cluster_reject title="2023 May 07" title_fontsize=14 font="Helvetica" fontsize=12 bgcolor=white border_color=white
d.out.file output=Guinea_Bissau_2023_reject format=jpg --overwrite
#d.rast.leg L8_2014_cluster_reject
#
# r.kappa - Calculates error matrix and kappa parameter for accuracy assessment of classification result.
g.region raster=L8_2023_cluster_classes -p
r.kappa -w classification=L8_2023_cluster_classes reference=L8_2015_cluster_classes

# export Kappa matrix as CSV file "kappa.csv"
r.kappa classification=L8_2023_cluster_classes reference=L8_2015_cluster_classes output=kappa.csv -m -h --overwrite


r.composite blue=L8_2023_07 green=L8_2023_06 red=L8_2023_04 \
            output=L8_2023_rgb --overwrite
r.composite blue=L8_2023_04 green=L8_2023_03 red=L8_2023_02 \
            output=L8_2023_rgb_nat --overwrite
r.composite blue=L8_2023_02 green=L8_2023_03 red=L8_2023_04 \
            output=L8_2023_rgb_nat_234 --overwrite
d.mon wx2
d.rast L8_2023_rgb_nat
d.out.file output=L8_2023_rgb_nat format=jpg --overwrite
