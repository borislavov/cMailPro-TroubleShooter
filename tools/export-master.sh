#!/bin/bash

head_hash=$(git log --oneline | head -n1  | cut -d' ' -f1);

out_dir_global=/tmp/
out_dir_local=cMailPro-TroubleShooter-git-${head_hash}
out_dir=${out_dir_global}/${out_dir_local}
out_file_local=cMailPro-TroubleShooter-git-${head_hash}.tar.bz2
out_file=${out_dir_global}/${out_file_local}

rm -rf ${out_dir}
#mkdir ${out_dir}
git archive --format=tar --prefix=cMailPro-TroubleShooter-git-${head_hash}/ HEAD | tar -xC   ${out_dir_global}

git log > ${out_dir}/Changelog-${head_hash}

cur_dir=$(pwd);
cd ${out_dir_global}

LC_ALL=C tar -cjf ${out_file} ${out_dir_local}

cd $cur_dir
mv ${out_file} ../

echo "File exported to " ${PWD}/../${out_file_local}
rm -rf ${out_dir}
