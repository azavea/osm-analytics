name := "osm-analytics"

val gtVer = "1.2.1"
val circeVer = "0.9.1"

scalaVersion := "2.11.11"

dependencyOverrides += "com.fasterxml.jackson.core" % "jackson-core" % "2.6.7"
dependencyOverrides += "com.fasterxml.jackson.core" % "jackson-databind" % "2.6.7"
dependencyOverrides += "com.fasterxml.jackson.module" % "jackson-module-scala_2.11" % "2.6.7"

libraryDependencies ++= Seq(
  // Deal with GeoMesa dependency that breaks Spark 2.2
  "org.json4s" %% "json4s-native" % "3.2.11",
  "org.json4s" %% "json4s-core" % "3.2.11",
  "org.json4s" %% "json4s-ast" % "3.2.11",

  "com.monovore" %% "decline" % "0.4.0",
  "org.apache.spark" %% "spark-hive" % "2.2.0" % "provided",
  "org.locationtech.geotrellis" %% "geotrellis-geotools" % gtVer
    exclude("com.google.protobuf", "protobuf-java"),
  "org.locationtech.geotrellis" %% "geotrellis-s3" % gtVer
    exclude("com.google.protobuf", "protobuf-java"),
  "org.locationtech.geotrellis" %% "geotrellis-spark" % gtVer
    exclude("com.google.protobuf", "protobuf-java"),
  "org.locationtech.geotrellis" %% "geotrellis-vector" % gtVer
    exclude("com.google.protobuf", "protobuf-java"),
  "org.locationtech.geotrellis" %% "geotrellis-vectortile" % gtVer
    exclude("com.google.protobuf", "protobuf-java"),
  "com.google.protobuf" % "protobuf-java" % "2.5.0",
  "com.azavea" %% "vectorpipe" % "0.2.2"
    exclude("com.google.protobuf", "protobuf-java"),
  "org.typelevel" %% "cats-core" % "1.0.0",
  "org.scalactic" %% "scalactic" % "3.0.3",
  "org.locationtech.geotrellis" %% "geotrellis-spark-testkit" % gtVer % "test",
  "com.typesafe.scala-logging" %% "scala-logging" % "3.5.0",
  "org.scalatest" %%  "scalatest" % "3.0.3" % "test",
  "io.circe" %% "circe-core" % circeVer,
  "io.circe" %% "circe-generic" % circeVer,
  "io.circe" %% "circe-parser" % circeVer
)

/* Fixes Spark breakage with `sbt run` as of sbt-1.0.2 */
fork in run := true

fork in Test := true

test in assembly := {}

javaOptions ++= Seq("-Xmx5G")

initialCommands in console :=
  """
  """

assemblyJarName in assembly := "osmesa-analytics.jar"

assemblyShadeRules in assembly := {
  val shadePackage = "com.azavea.shaded.demo"
  Seq(
    ShadeRule.rename("com.google.common.**" -> s"$shadePackage.google.common.@1")
      .inLibrary("com.azavea.geotrellis" %% "geotrellis-cassandra" % gtVer).inAll,
    ShadeRule.rename("io.netty.**" -> s"$shadePackage.io.netty.@1")
      .inLibrary("com.azavea.geotrellis" %% "geotrellis-hbase" % gtVer).inAll,
    ShadeRule.rename("com.fasterxml.jackson.**" -> s"$shadePackage.com.fasterxml.jackson.@1")
      .inLibrary("com.networknt" % "json-schema-validator" % "0.1.7").inAll,
    ShadeRule.rename("org.apache.avro.**" -> s"$shadePackage.org.apache.avro.@1")
      .inLibrary("com.azavea.geotrellis" %% "geotrellis-spark" % gtVer).inAll
  )
}

assemblyMergeStrategy in assembly := {
  case s if s.startsWith("META-INF/services") => MergeStrategy.concat
  case "reference.conf" | "application.conf"  => MergeStrategy.concat
  case "META-INF/MANIFEST.MF" | "META-INF\\MANIFEST.MF" => MergeStrategy.discard
  case "META-INF/ECLIPSEF.RSA" | "META-INF/ECLIPSEF.SF" => MergeStrategy.discard
  case _ => MergeStrategy.first
}

assemblyOption in assembly := (assemblyOption in assembly).value.copy(includeScala = false)
