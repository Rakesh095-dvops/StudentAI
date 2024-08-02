const { Organization } = require("../models/organization.model");

// Get all organizations
const getAllOrganizations = async (req, res) => {
  try {
    const organizations = await Organization.find();
    res.status(200).json(organizations);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Get an organization by ID
const getOrganizationById = async (req, res) => {
  try {
    const organization = await Organization.findById(req.params.id);
    if (!organization)
      return res.status(404).json({ message: "Organization not found" });
    res.status(200).json(organization);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Create a new organization
const createOrganization = async (req, res) => {
  try {
    const { organizationName, email, phoneNo } = req.body;
    console.log("req.body: ", req.body);

    const organization = new Organization({
      organizationName,
      email,
      phoneNo,
    });

    const newOrganization = await organization.save();
    res.status(201).json(newOrganization);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Update an organization by ID
const updateOrganization = async (req, res) => {
  const { organizationName, email, phoneNo } = req.body;

  try {
    const organization = await Organization.findById(req.params.id);
    if (!organization)
      return res.status(404).json({ message: "Organization not found" });

    if (organizationName) organization.organizationName = organizationName;
    if (email) organization.email = email;
    if (phoneNo) organization.phoneNo = phoneNo;

    const updatedOrganization = await organization.save();
    res.status(200).json(updatedOrganization);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Delete an organization by ID
const deleteOrganization = async (req, res) => {
  try {
    const organization = await Organization.findById(req.params.id);
    if (!organization)
      return res.status(404).json({ message: "Organization not found" });

    await organization.remove();
    res.status(200).json({ message: "Organization deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  getAllOrganizations,
  getOrganizationById,
  createOrganization,
  updateOrganization,
  deleteOrganization,
};
