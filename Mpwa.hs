{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PackageImports    #-}

import           "lens" Control.Lens                              (view)
import           "bytestring" Data.ByteString                           as BS (readFile)
import           "proto-lens" Data.ProtoLens                            (decodeMessageOrDie)
import           "vector" Data.Vector.Storable                      as V
import qualified "tensorflow-proto" Proto.Tensorflow.Core.Protobuf.MetaGraph  as MetaGraph
import qualified "tensorflow-proto" Proto.Tensorflow.Core.Protobuf.SavedModel as SavedModel
import qualified "tensorflow" TensorFlow.Core                           as TF
import qualified "tensorflow" TensorFlow.Tensor                         as TF

main :: IO ()
main = do
  let path = "/home/jonny/tensorflow2/TensorFlow-ENet/savedmodel_mpwa/saved_model.pb"
  savedModel <- decodeMessageOrDie <$> BS.readFile path :: IO SavedModel.SavedModel
  let [metaGraph] = view SavedModel.metaGraphs savedModel
      graphDef    = view MetaGraph.graphDef metaGraph

  tensor <- TF.runSession $ do
    TF.build $ TF.addGraphDef graphDef
    TF.run $ TF.tensorRefFromName "Const" :: TF.Session (V.Vector Float)
  putStrLn $ show tensor
