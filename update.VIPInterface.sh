#!/usr/bin/env bash
if [ -n "$1" ]; then
echo "usually update once"
fi

## finished setting up ------
strPath="$(python -c 'import site; print(site.getsitepackages()[0])')"
strweb="${strPath}/backend/czi_hosted/common/web/static/."

cp VIPInterface.py $strPath/backend/czi_hosted/app/.
cp interface.html $strweb
cp vip.env $strPath/backend/czi_hosted/app/. 2>/dev/null | true

cp fgsea.R $strPath/backend/czi_hosted/app/.
mkdir -p $strPath/backend/czi_hosted/app/gsea
cp gsea/*gmt $strPath/backend/czi_hosted/app/gsea
cp complexHeatmap.R $strPath/backend/czi_hosted/app/.
cp volcano.R $strPath/backend/czi_hosted/app/.

if [ -n "$1" ]; then
  cp Density2D.R $strPath/backend/czi_hosted/app/.
  cp bubbleMap.R $strPath/backend/czi_hosted/app/.
  cp violin.R $strPath/backend/czi_hosted/app/.
  cp volcano.R $strPath/backend/czi_hosted/app/.
  cp browserPlot.R $strPath/backend/czi_hosted/app/.
  cp complexHeatmap.R $strPath/backend/czi_hosted/app/.
  if [ "$(uname -s)" = "Darwin" ]; then
    sed -i .bak "s|route(request.data,current_app.app_config, \"/tmp\")|route(request.data,current_app.app_config)|" "$strPath/backend/czi_hosted/app/app.py"
    sed -i .bak "s|MAX_LAYOUTS *= *[0-9]\+|MAX_LAYOUTS = 300|" "$strPath/backend/common/constants.py"
  else
    sed -i "s|route(request.data,current_app.app_config, \"/tmp\")|route(request.data,current_app.app_config)|" "$strPath/backend/czi_hosted/app/app.py"
    sed -i "s|MAX_LAYOUTS *= *[0-9]\+|MAX_LAYOUTS = 300|" "$strPath/backend/common/constants.py"
  fi

  find ./cellxgene/backend/ -name "decode_fbs.py" -exec cp {} $strPath/backend/czi_hosted/app/. \;
fi

echo -e "\nls -l $strweb\n"
ls -l $strweb
