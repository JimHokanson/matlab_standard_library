-- -- -- -- HDS-Toolbox -- -- -- --
--
-- Copyright (C) 2012 J.B.Wagenaar
--      All Rights Reserved.
-- -- -- -- -- -- -- -- -- -- -- --
Version: 2.1.1


The HDS-Toolbox provides a means to access large amounts of 'scientific' data in a structured and intuitive way in Matlab. It aims to create datasets that are self-explanatory and tailored to the specific needs of the user by allowing the user to define the hierarchy of the objects. It provides a transparent alternative for people that currently store their scientific data in matlab-structures and offers many additional benefits which will be described in the remainder of this document.

The toolbox does this by requiring the user to define their data as a set of linked classes which are hierarchically organized. Objects of these classes can be linked to each-other based on the relations defined in the class definitions. The class definitions separate 'meta-data' from 'raw-data' and assigns dimensions and units to data represented in the objects.

Representing data in objects has multiple advantages. First, the user is required to define a class definition for each data type. This standardizes the data sets and enforces clear descriptions of the contents of a data set. Second, classes can have associated methods which means that specific analysis method can be written for objects of a certain class. These methods are all stored with the class definition and are therefore easily managed. In addition, it is easy to list all methods that can be invoked for a certain data class. In general, using an object oriented structure for scientific data will enforce a more structured approach to defining data and methods.

Accessing data with the HDS Toolbox is as easy as indexing a Matlab structure. By altering the way that MATLAB accesses data in properties, the HDS Toolbox can load data from disk at the time the property is accessed. Once the data is loaded from disk, the data remains in memory until the user clears the memory. In addition, the data in the objects is stored separately from the meta-data which enables very fast browsing of objects with a very limited memory load.

In summary, the HDS Toolbox provides a solution for scientists who analyze and store scientific data with Matlab. It enables the user to categorize and structure their data in a manner that enforces uniformity and 'readability' . It also enables the user to access all the data through a highly intuitive way while keeping memory requirements to a minimum.