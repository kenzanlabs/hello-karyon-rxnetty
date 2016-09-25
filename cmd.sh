#!/bin/bash
BASE_DIR=$(pwd)

APP_NAME="hello-karyon-rxnetty"
GCR_TAG=gcr.io/cloud-armory/${APP_NAME}
SLEEP=${WAIT_TIME:-35}
DOCKER_RUN="docker run -i -t"

build() {
  docker build -t ${GCR_TAG} -f Dockerfile .
}

test() {
  $DOCKER_RUN \
    -v ${BASE_DIR}/armory:/home/armory/armory \
    -v ${BASE_DIR}/bin:/home/armory/bin \
    $GCR_TAG \
    bash -c "nosetests"
}

run() {
  echo ${BASE_DIR}
  docker run \
    -it \
    -v ${BASE_DIR}/build/distributions:/home/spinnaker/distributions/ \
    $GCR_TAG \
    /bin/bash
}

deploy() {
  gcloud container clusters describe armory-kube --zone=us-central1-c > /dev/null 2>&1
  kubectl config use-context gke_cloud-armory_us-central1-c_armory-kube
  if [ "$?" -ne 0 ]
  then
      echo "couldn't find the 'armory-kube' cluster, exiting"
      exit 1
  fi

  kubectl delete -f etc/kube/pod.yaml
  echo "Sleeping for ${SLEEP} seconds"
  for i in $(seq 1 $SLEEP);
  do
    sleep 1
    echo -n "."
  done
  echo "."
  kubectl create -f etc/kube/pod.yaml
}

push() {
  gcloud docker push ${GCR_TAG}
}

shell() {
  $DOCKER_RUN \
  -v ${BASE_DIR}/armory:/home/armory/armory \
  ${GCR_TAG} /bin/bash
}

container() {
  image_id=$(docker ps --filter=ancestor=$GCR_TAG | tail -1 | awk '{ print $1 }')
  docker exec -i -t $image_id /bin/bash
}



clean() {
  find ./armory/ -type f -name '*.pyc' -delete
  docker kill $(docker ps -q)
  docker rm -v $(docker ps -a -q -f status=exited)
  docker rmi -f $(docker images -f "dangling=true" -q)
}

usage() {
    echo "$0 [build|cd|container|clean|run|shell|deploy|push|test]"
}

[ $# -lt 1 ] && usage && exit 1
OPT=$1

case $OPT in
    cd)
      build && test && push && deploy
      ;;
    container)
      container
      ;;
    clean)
      clean
      ;;
    docker_entrypoint)
      docker_entrypoint
      ;;
    push)
      push
      ;;
    deploy)
      deploy
      ;;
    build)
      build
      ;;
    run)
      build && run
      ;;
    shell)
      shell
      ;;
    test)
      test $@
      ;;
    *)
      usage
      exit 2
      ;;
esac
